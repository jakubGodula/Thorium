import re

with open('ui/src/App.svelte', 'r') as f:
    content = f.read()

# Replace startVM
content = re.sub(
    r'const startVM = async \(agent: Agent\) => \{.*?try \{.*?const targetUrl.*?\n.*?const res = await fetch.*?body: JSON\.stringify.*?\}\);\n.*?if \(res\.ok\) fetchVMs\(\);\n.*?\} catch \(e\) \{\}\n\s*\}\;',
    '''const startVM = async (agent: Agent) => {
    if (window.wsConnections && window.wsConnections["local"] && window.wsConnections["local"].readyState === WebSocket.OPEN) {
        window.wsConnections["local"].send(JSON.stringify({ method: "start_vm", name: agent.fullId }));
    }
  };''',
    content, flags=re.DOTALL
)

# Replace stopVM
content = re.sub(
    r'const stopVM = async \(agent: Agent\) => \{.*?try \{.*?const targetUrl.*?\n.*?const res = await fetch.*?body: JSON\.stringify.*?\}\);\n.*?if \(res\.ok\) fetchVMs\(\);\n.*?\} catch \(e\) \{\}\n\s*\}\;',
    '''const stopVM = async (agent: Agent) => {
    if (window.wsConnections && window.wsConnections["local"] && window.wsConnections["local"].readyState === WebSocket.OPEN) {
        window.wsConnections["local"].send(JSON.stringify({ method: "stop_vm", name: agent.fullId }));
    }
  };''',
    content, flags=re.DOTALL
)

# Replace isolateHost
content = re.sub(
    r'const isolateHost = async \(agent: Agent\) => \{.*?try \{.*?const targetUrl.*?fetch\(targetUrl\);.*?if \(res\.ok\) \{.*?\}\n.*?\} catch \(_\) \{\}\n\s*\}\;',
    '''const isolateHost = async (agent: Agent) => {
    if (window.wsConnections && window.wsConnections["local"] && window.wsConnections["local"].readyState === WebSocket.OPEN) {
        window.wsConnections["local"].send(JSON.stringify({ method: "isolate_vm", name: agent.fullId }));
    }
  };''',
    content, flags=re.DOTALL
)

# Replace restoreHost
content = re.sub(
    r'const restoreHost = async \(agent: Agent\) => \{.*?try \{.*?const targetUrl.*?fetch\(targetUrl\);.*?if \(res\.ok\) \{.*?\}\n.*?\} catch \(_\) \{\}\n\s*\}\;',
    '''const restoreHost = async (agent: Agent) => {
    if (window.wsConnections && window.wsConnections["local"] && window.wsConnections["local"].readyState === WebSocket.OPEN) {
        window.wsConnections["local"].send(JSON.stringify({ method: "restore_vm", name: agent.fullId }));
    }
  };''',
    content, flags=re.DOTALL
)

# Replace fetchLogs
content = re.sub(
    r'const fetchLogs = async \(\) => \{.*?if \(!showLogsModal \|\| \!selectedAgentForLogs\) return;.*?try \{.*?const targetUrl.*?fetch.*?body: JSON\.stringify.*?\}\);\n.*?if \(res\.ok\).*?\}\n.*?\} catch \(err\) \{.*?\}\n\s*\};',
    '''const fetchLogs = async () => {
    if (!showLogsModal || !selectedAgentForLogs) return;
    if (window.wsConnections && window.wsConnections[selectedAgentForLogs.id] && window.wsConnections[selectedAgentForLogs.id].readyState === WebSocket.OPEN) {
        // liveLogs will be updated by the main WS onmessage handler if we set a global selected agent.
        // Or we can just send the request.
        window.wsConnections[selectedAgentForLogs.id].send(JSON.stringify({ method: "get_logs" }));
    }
  };''',
    content, flags=re.DOTALL
)

with open('ui/src/App.svelte', 'w') as f:
    f.write(content)

