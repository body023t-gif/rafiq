import json

with open(r'C:\Users\dell\.gemini\antigravity\brain\8fa31a88-7487-428c-9cea-0a5b05cd7377\.system_generated\logs\transcript.jsonl', 'r', encoding='utf-8') as f:
    for line in f:
        try:
            data = json.loads(line)
            if data.get('type') == 'USER_INPUT':
                content = data.get('content')
                if 'AI202' in content or '"lecture"' in content:
                    log(f"--- MSG {data.get('step_index')} ---")
                    log(content)
        except:
            pass
