use aya::{
    programs::{TracePoint, KProbe},
    maps::perf::AsyncPerfEventArray,
    util::online_cpus,
    Ebpf,
};
use bytes::BytesMut;
use thorium_ebpf_common::{ProcessEvent, NetworkEvent};
use serde_json::json;
use std::net::Ipv4Addr;
use tokio::signal;

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    #[cfg(debug_assertions)]
    let bpf_data = include_bytes!("../../target/bpfel-unknown-none/debug/thorium_ebpf");
    #[cfg(not(debug_assertions))]
    let bpf_data = include_bytes!("../../target/bpfel-unknown-none/release/thorium_ebpf");

    let mut bpf = Ebpf::load(bpf_data)?;

    let program: &mut TracePoint = bpf.program_mut("thorium_ebpf").unwrap().try_into()?;
    program.load()?;
    program.attach("syscalls", "sys_enter_execve")?;

    let kprobe: &mut KProbe = bpf.program_mut("thorium_tcp_connect").unwrap().try_into()?;
    kprobe.load()?;
    kprobe.attach("tcp_v4_connect", 0)?;

    let mut perf_array = AsyncPerfEventArray::try_from(bpf.take_map("EVENTS").unwrap())?;
    for cpu_id in online_cpus().map_err(|(_, e)| anyhow::anyhow!("{}", e))? {
        let mut buf = perf_array.open(cpu_id, None)?;
        tokio::spawn(async move {
            let mut buffers = (0..10).map(|_| BytesMut::with_capacity(1024)).collect::<Vec<_>>();
            loop {
                let events = buf.read_events(&mut buffers).await.unwrap();
                for i in 0..events.read {
                    let buf = &mut buffers[i];
                    let event = unsafe { std::ptr::read_unaligned(buf.as_ptr() as *const ProcessEvent) };
                    
                    let cmd_str = std::ffi::CStr::from_bytes_until_nul(&event.command)
                        .map(|c| c.to_string_lossy().into_owned())
                        .unwrap_or_else(|_| String::from_utf8_lossy(&event.command).into_owned());

                    let ts = std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_secs();
                    let h = (ts / 3600) % 24 + 2;
                    let m = (ts / 60) % 60;
                    let s = ts % 60;
                    let time_str = format!("[{:02}:{:02}:{:02}]", h, m, s);
                    
                    let log = json!({
                        "typ": "PROCES_START",
                        "cmd": cmd_str,
                        "pid": event.pid as f64,
                        "uid": event.uid as f64,
                        "czas": time_str
                    });
                    println!("{}", log);
                }
            }
        });
    }

    let mut net_perf_array = AsyncPerfEventArray::try_from(bpf.take_map("NET_EVENTS").unwrap())?;
    for cpu_id in online_cpus().map_err(|(_, e)| anyhow::anyhow!("{}", e))? {
        let mut buf = net_perf_array.open(cpu_id, None)?;
        tokio::spawn(async move {
            let mut buffers = (0..10).map(|_| BytesMut::with_capacity(1024)).collect::<Vec<_>>();
            loop {
                let events = buf.read_events(&mut buffers).await.unwrap();
                for i in 0..events.read {
                    let buf = &mut buffers[i];
                    let event = unsafe { std::ptr::read_unaligned(buf.as_ptr() as *const NetworkEvent) };
                    
                    let ts = std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_secs();
                    let h = (ts / 3600) % 24 + 2;
                    let m = (ts / 60) % 60;
                    let s = ts % 60;
                    let time_str = format!("[{:02}:{:02}:{:02}]", h, m, s);
                    
                    let log = json!({
                        "typ": "POŁĄCZENIE",
                        "pid": event.pid as f64,
                        "saddr": Ipv4Addr::from(u32::from_be(event.saddr)).to_string(),
                        "daddr": Ipv4Addr::from(u32::from_be(event.daddr)).to_string(),
                        "sport": u16::from_be(event.sport) as f64,
                        "dport": u16::from_be(event.dport) as f64,
                        "is_incoming": event.is_incoming,
                        "czas": time_str
                    });
                    println!("{}", log);
                }
            }
        });
    }

    signal::ctrl_c().await?;
    Ok(())
}
