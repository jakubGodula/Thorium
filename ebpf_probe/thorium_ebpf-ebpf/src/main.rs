#![no_std]
#![no_main]

use aya_ebpf::{
    macros::{tracepoint, kprobe, map, lsm},
    programs::{TracePointContext, ProbeContext, LsmContext},
    maps::{PerfEventArray, HashMap},
    helpers::{
        bpf_get_current_pid_tgid,
        bpf_get_current_uid_gid,
        bpf_get_current_comm,
        bpf_probe_read_kernel,
    },
};
use thorium_ebpf_common::{ProcessEvent, NetworkEvent};

#[map]
static EVENTS: PerfEventArray<ProcessEvent> = PerfEventArray::new(0);

#[map]
static NET_EVENTS: PerfEventArray<NetworkEvent> = PerfEventArray::new(0);

/// Deduplikacja połączeń sieciowych per (pid, daddr, dport)
#[map]
static NET_SEEN: HashMap<u64, u8> = HashMap::with_max_entries(1024, 0);

/// Przechowuje nazwę pliku odczytaną w sys_enter_execve
#[map]
static EXEC_PENDING: HashMap<u32, [u8; 256]> = HashMap::with_max_entries(4096, 0);

/// Drzewo procesów: mapowanie child_pid -> parent_pid (do agregacji)
#[map]
static PARENT_MAP: HashMap<u32, u32> = HashMap::with_max_entries(8192, 0);

#[inline(always)]
fn read_command_with_args(filename_ptr: u64, argv_ptr: u64, buf: &mut [u8; 256]) {
    let mut offset = 0;
    if filename_ptr != 0 {
        if let Ok(slice) = unsafe { aya_ebpf::helpers::bpf_probe_read_user_str_bytes(filename_ptr as *const u8, buf) } {
            let mut l = slice.len();
            if l > 0 && buf[l - 1] == 0 { l -= 1; }
            offset = l;
        }
    }
    
    if argv_ptr != 0 && offset > 0 && offset < 250 {
        // Czytaj maksymalnie 3 argumenty
        for i in 1..4 {
            let res = unsafe { aya_ebpf::helpers::bpf_probe_read_user((argv_ptr + i * 8) as *const u64) };
            let arg_ptr = match res {
                Ok(ptr) => ptr,
                Err(_) => break,
            };
            if arg_ptr == 0 { break; }
            
            buf[offset] = b' ';
            offset += 1;
            let mut arg_buf = [0u8; 64];
            if let Ok(slice) = unsafe { aya_ebpf::helpers::bpf_probe_read_user_str_bytes(arg_ptr as *const u8, &mut arg_buf) } {
                let mut l = slice.len();
                if l > 0 && arg_buf[l - 1] == 0 { l -= 1; }
                let copy_len = core::cmp::min(l, 255 - offset);
                if copy_len > 0 {
                    unsafe { core::ptr::copy_nonoverlapping(arg_buf.as_ptr(), buf.as_mut_ptr().add(offset), copy_len); }
                    offset += copy_len;
                }
            }
            if offset >= 250 { break; }
        }
    }
}

// ─── sys_enter_execve: czytamy ścieżkę zanim exec podmieni pamięć ─────────
#[tracepoint]
pub fn thorium_ebpf_enter(ctx: TracePointContext) -> u32 {
    let pid_tgid = bpf_get_current_pid_tgid();
    let tgid = (pid_tgid >> 32) as u32;

    let filename_ptr: u64 = unsafe { ctx.read_at(16).unwrap_or(0) };
    let argv_ptr: u64 = unsafe { ctx.read_at(24).unwrap_or(0) };
    
    if filename_ptr != 0 {
        let mut buf = [0u8; 256];
        read_command_with_args(filename_ptr, argv_ptr, &mut buf);
        let _ = unsafe { EXEC_PENDING.insert(&tgid, &buf, 0) };
    }
    0
}

// ─── sys_enter_execveat: wskaźnik do filename jest pod offsetem 24 ────────
#[tracepoint]
pub fn thorium_ebpf_enter_at(ctx: TracePointContext) -> u32 {
    let pid_tgid = bpf_get_current_pid_tgid();
    let tgid = (pid_tgid >> 32) as u32;

    let filename_ptr: u64 = unsafe { ctx.read_at(24).unwrap_or(0) };
    let argv_ptr: u64 = unsafe { ctx.read_at(32).unwrap_or(0) };
    
    if filename_ptr != 0 {
        let mut buf = [0u8; 256];
        read_command_with_args(filename_ptr, argv_ptr, &mut buf);
        let _ = unsafe { EXEC_PENDING.insert(&tgid, &buf, 0) };
    }
    0
}

// ─── sys_exit_execve: emitujemy event tylko jeśli ret == 0 ────────────────
#[tracepoint]
pub fn thorium_ebpf(ctx: TracePointContext) -> u32 {
    let pid_tgid = bpf_get_current_pid_tgid();
    let tgid = (pid_tgid >> 32) as u32;

    // sys_exit_execve: retval jest pod offsetem 16
    let retval: i64 = unsafe { ctx.read_at(16).unwrap_or(-1) };

    // Pobierz odczytaną wcześniej ścieżkę
    if let Some(cmd_ptr) = unsafe { EXEC_PENDING.get(&tgid) } {
        if retval == 0 {
            let uid = bpf_get_current_uid_gid() as u32;
            let ppid = unsafe { PARENT_MAP.get(&tgid).copied().unwrap_or(0) };
            
            let mut event = ProcessEvent {
                pid: tgid,
                ppid,
                uid,
                command: [0u8; 256],
            };
            
            // Kopiujemy odczytany string z mapy
            unsafe {
                core::ptr::copy_nonoverlapping(
                    cmd_ptr.as_ptr(),
                    event.command.as_mut_ptr(),
                    256
                );
            }
            EVENTS.output(&ctx, &event, 0);
        }
    }
    
    // Zawsze czyścimy wpis, niezależnie czy exec się udał czy nie
    let _ = unsafe { EXEC_PENDING.remove(&tgid) };
    0
}

// ─── sched_process_fork: rejestracja ppid ─────────────────────────────────
#[tracepoint]
pub fn thorium_ebpf_fork(ctx: TracePointContext) -> u32 {
    let parent_pid: u32 = unsafe { ctx.read_at(12).unwrap_or(0) };
    let child_pid: u32 = unsafe { ctx.read_at(20).unwrap_or(0) };
    
    if child_pid != 0 {
        let _ = unsafe { PARENT_MAP.insert(&child_pid, &parent_pid, 0) };
    }
    0
}

// ─── sched_process_exit: czyszczenie mapy ─────────────────────────────────
#[tracepoint]
pub fn thorium_ebpf_exit(_ctx: TracePointContext) -> u32 {
    let pid_tgid = bpf_get_current_pid_tgid();
    let tgid = (pid_tgid >> 32) as u32;
    let _ = unsafe { PARENT_MAP.remove(&tgid) };
    0
}

// ─── tcp_v4_connect kprobe ────────────────────────────────────────────────
#[kprobe]
pub fn thorium_tcp_connect(ctx: ProbeContext) -> u32 {
    match try_tcp_connect(ctx) {
        Ok(ret) => ret,
        Err(_) => 0,
    }
}

fn try_tcp_connect(ctx: ProbeContext) -> Result<u32, i64> {
    let pid_tgid = bpf_get_current_pid_tgid();
    let pid = (pid_tgid >> 32) as u32;

    // arg1 = struct sockaddr *uaddr, arg2 = addrlen
    let sockaddr_ptr: u64 = unsafe { ctx.arg(1).ok_or(0i64)? };
    if sockaddr_ptr == 0 { return Ok(0); }

    // sockaddr_in: sa_family(2) + sin_port(2 BE) + sin_addr(4 BE)
    let sa: [u8; 8] = unsafe {
        bpf_probe_read_kernel(&*(sockaddr_ptr as *const [u8; 8])).map_err(|e| e)?
    };

    let dport = u16::from_be_bytes([sa[2], sa[3]]);
    let daddr = u32::from_be_bytes([sa[4], sa[5], sa[6], sa[7]]);

    // Pomiń loopback (127.x.x.x) i adresy zerowe
    if daddr == 0 || (daddr >> 24) == 127 { return Ok(0); }

    // Deduplikacja kernelowa
    let dedup_key: u64 = ((pid as u64) << 32) | ((daddr as u64) ^ (dport as u64));
    if unsafe { NET_SEEN.get(&dedup_key) }.is_some() { return Ok(0); }
    let _ = unsafe { NET_SEEN.insert(&dedup_key, &1u8, 0) };

    let event = NetworkEvent {
        pid,
        saddr: 0,
        daddr,
        daddr_v6: [0; 16],
        sport: 0,
        dport,
        is_incoming: false,
        is_ipv6: false,
        _pad: [0; 2],
    };
    NET_EVENTS.output(&ctx, &event, 0);
    Ok(0)
}

// ─── tcp_v6_connect kprobe ────────────────────────────────────────────────
#[kprobe]
pub fn thorium_tcp_v6_connect(ctx: ProbeContext) -> u32 {
    match try_tcp_v6_connect(ctx) {
        Ok(ret) => ret,
        Err(_) => 0,
    }
}

fn try_tcp_v6_connect(ctx: ProbeContext) -> Result<u32, i64> {
    let pid_tgid = bpf_get_current_pid_tgid();
    let pid = (pid_tgid >> 32) as u32;

    let sockaddr_ptr: u64 = unsafe { ctx.arg(1).ok_or(0i64)? };
    if sockaddr_ptr == 0 { return Ok(0); }

    // sockaddr_in6: sin6_family(2) + sin6_port(2 BE) + sin6_flowinfo(4) + sin6_addr(16)
    let sa: [u8; 24] = unsafe {
        bpf_probe_read_kernel(&*(sockaddr_ptr as *const [u8; 24])).map_err(|e| e)?
    };

    let dport = u16::from_be_bytes([sa[2], sa[3]]);
    let mut daddr_v6 = [0u8; 16];
    daddr_v6.copy_from_slice(&sa[8..24]);

    // Odrzuć loopback (::1) i zero
    if daddr_v6 == [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1] || daddr_v6 == [0; 16] { return Ok(0); }

    let daddr_hash = u32::from_ne_bytes([daddr_v6[0], daddr_v6[1], daddr_v6[2], daddr_v6[3]])
        ^ u32::from_ne_bytes([daddr_v6[4], daddr_v6[5], daddr_v6[6], daddr_v6[7]])
        ^ u32::from_ne_bytes([daddr_v6[8], daddr_v6[9], daddr_v6[10], daddr_v6[11]])
        ^ u32::from_ne_bytes([daddr_v6[12], daddr_v6[13], daddr_v6[14], daddr_v6[15]]);

    let dedup_key: u64 = ((pid as u64) << 32) | ((daddr_hash as u64) ^ (dport as u64));
    if unsafe { NET_SEEN.get(&dedup_key) }.is_some() { return Ok(0); }
    let _ = unsafe { NET_SEEN.insert(&dedup_key, &1u8, 0) };

    let event = NetworkEvent {
        pid,
        saddr: 0,
        daddr: 0,
        daddr_v6,
        sport: 0,
        dport,
        is_incoming: false,
        is_ipv6: true,
        _pad: [0; 2],
    };
    NET_EVENTS.output(&ctx, &event, 0);
    Ok(0)
}

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    unsafe { core::hint::unreachable_unchecked() }
}

// ─── Active Pre-Execution (BPF LSM) ───────────────────────────────────────
#[lsm(hook = "bprm_check_security")]
pub fn thorium_lsm_bprm_check(ctx: LsmContext) -> i32 {
    let mut comm = [0u8; 16];
    if bpf_get_current_comm(&mut comm).is_err() {
        return 0; // W razie błędu odczytu, zezwól na uruchomienie
    }

    // Przykładowa natywna blokada złośliwych narzędzi w Ring-0
    // Zapobiega uruchomieniu programu zanim kernel przydzieli mu wirtualną pamięć.
    if &comm[0..4] == b"nmap" || &comm[0..5] == b"mimik" {
        return -1; // -EPERM (Odmowa dostępu z pominięciem SIGKILL)
    }

    0 // Zezwól na uruchomienie
}
