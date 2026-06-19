use anyhow::{Context, Result};
use std::env;
use std::process::Command;

fn main() -> Result<()> {
    let mut args = env::args().skip(1);
    let task = args.next();

    match task.as_deref() {
        Some("build-ebpf") => build_ebpf()?,
        Some("build") => {
            build_ebpf()?;
            build_userspace()?;
        }
        Some("run") => {
            build_ebpf()?;
            build_userspace()?;
            run_userspace()?;
        }
        _ => print_help(),
    }

    Ok(())
}

fn print_help() {
    eprintln!("Tasks:");
    eprintln!("  build-ebpf  - Skompiluj wstawkę BPF (wymaga nightly Rusta)");
    eprintln!("  build       - Skompiluj eBPF i user-space");
    eprintln!("  run         - Zbuduj wszystko i uruchom testowo przez sudo");
}

fn build_ebpf() -> Result<()> {
    println!(">>> Kompilowanie wstawki eBPF z użyciem nightly...");
    
    // Używamy nightly i wymuszamy bpf-linker
    let status = Command::new("cargo")
        .current_dir("thorium_ebpf-ebpf")
        .args(&[
            "+nightly",
            "build",
            "--release",
            "--target",
            "bpfel-unknown-none",
            "-Z",
            "build-std=core",
        ])
        .status()
        .context("Błąd kompilacji. Upewnij się, że masz zainstalowany toolchain nightly (rustup toolchain install nightly --component rust-src) oraz bpf-linker.")?;

    if !status.success() {
        anyhow::bail!("Kompilacja wstawki BPF zakończona niepowodzeniem.");
    }
    
    // Aya macro include_bytes! oczekuje pliku `thorium_ebpf` (bez -ebpf)
    let target_dir = std::path::PathBuf::from("target/bpfel-unknown-none/release");
    std::fs::create_dir_all(&target_dir).ok();
    
    let compiled_ebpf = std::path::PathBuf::from("thorium_ebpf-ebpf/target/bpfel-unknown-none/release/thorium_ebpf-ebpf");
    let dest_ebpf = target_dir.join("thorium_ebpf");
    
    if compiled_ebpf.exists() {
        std::fs::copy(&compiled_ebpf, &dest_ebpf).context("Nie udało się skopiować pliku ELF do docelowej nazwy")?;
    }
    
    println!(">>> Wstawka BPF przygotowana w target/bpfel-unknown-none/release/thorium_ebpf.");
    Ok(())
}

fn build_userspace() -> Result<()> {
    println!(">>> Kompilowanie programu uzytkownika...");
    let status = Command::new("cargo")
        .current_dir("thorium_ebpf")
        .args(&["build", "--release"])
        .status()
        .context("Kompilacja user-space nie powiodła się")?;

    if !status.success() {
        anyhow::bail!("Błąd kompilacji user-space.");
    }
    
    println!(">>> Program user-space skompilowany.");
    Ok(())
}

fn run_userspace() -> Result<()> {
    println!(">>> Uruchamianie (wymaga sudo)...");
    let status = Command::new("sudo")
        .current_dir("thorium_ebpf")
        .args(&["-E", "../target/release/thorium_ebpf"])
        .status()
        .context("Nie udało się uruchomić procesu.")?;

    if !status.success() {
        anyhow::bail!("Zakończono błędem.");
    }
    Ok(())
}
