#![no_std]

#[repr(C)]
#[derive(Clone, Copy)]
pub struct ProcessEvent {
    pub pid: u32,
    pub ppid: u32,
    pub uid: u32,
    pub command: [u8; 256],
}

#[repr(C)]
#[derive(Clone, Copy)]
pub struct NetworkEvent {
    pub pid: u32,
    pub saddr: u32,
    pub daddr: u32,
    pub daddr_v6: [u8; 16],
    pub sport: u16,
    pub dport: u16,
    pub is_incoming: bool,
    pub is_ipv6: bool,
    pub _pad: [u8; 2],
}

#[cfg(feature = "user")]
unsafe impl aya::Pod for ProcessEvent {}

#[cfg(feature = "user")]
unsafe impl aya::Pod for NetworkEvent {}
