# 4️⃣ Claude 연동 — 메모를 AI가 읽고 쓰게 하기

목표: **Claude가 옵시디언 볼트의 메모를 직접 읽고, 정리하고, 새로 써주게** 만들기.

기기별로 방법이 다릅니다. **연동은 Mac(컴퓨터)에서 이뤄지고**, 아이폰·아이패드는 iCloud로 동기화된 결과를 보는 구조라고 이해하면 편해요.

---

## 🖥 방법 1) Claude Desktop + Obsidian MCP (Mac, 가장 강력) ⭐

Claude 데스크톱 앱이 옵시디언 볼트에 직접 접근하게 만듭니다. "인박스 정리해줘" 하면 실제 파일을 읽고 씁니다.

### 준비물
- Mac용 **Claude Desktop 앱** (claude.ai/download)
- 옵시디언 **Local REST API** 커뮤니티 플러그인
- **Node.js** (https://nodejs.org 에서 LTS 설치)

### 단계
**① 옵시디언에 Local REST API 플러그인 설치**
1. 옵시디언 → Settings → Community plugins → Browse
2. **"Local REST API"** 검색 → Install → Enable
3. 플러그인 설정에서 **API Key**를 복사해 둡니다 (나중에 필요)

**② Claude Desktop에 MCP 서버 등록**
1. Claude Desktop → Settings → **Developer → Edit Config** (또는 아래 파일 직접 편집)
   `~/Library/Application Support/Claude/claude_desktop_config.json`
2. 아래 내용을 넣습니다 (API Key는 ①에서 복사한 값으로):

```json
{
  "mcpServers": {
    "obsidian": {
      "command": "npx",
      "args": ["-y", "obsidian-mcp-server"],
      "env": {
        "OBSIDIAN_API_KEY": "여기에_복사한_API_KEY",
        "OBSIDIAN_BASE_URL": "http://127.0.0.1:27123"
      }
    }
  }
}
```

> 참고: MCP 서버 패키지는 여러 종류가 있어요 (`obsidian-mcp-server`, `mcp-obsidian` 등).
> 위가 안 되면 npm에서 "obsidian mcp"로 검색해 최신 패키지명으로 바꿔 넣으세요.
> 각 패키지의 README에 필요한 `env` 변수(API 키/포트)가 적혀 있습니다.

**③ Claude Desktop 재시작**
- 완전 종료 후 다시 실행 → 채팅창에 🔌(MCP) 아이콘/도구가 보이면 성공
- "내 옵시디언 인박스에 뭐 있어?" 라고 물어보면 실제 메모를 읽어옵니다

---

## 💻 방법 2) Claude Code (개발자/파워유저용, Mac)

지금 이 대화처럼 **Claude Code**를 볼트 폴더에서 실행하면, 별도 플러그인 없이 메모 파일을 바로 읽고 씁니다.

1. Mac 터미널에서 볼트 폴더로 이동: `cd ~/경로/나의볼트`
2. `claude` 실행
3. "10-Notes 정리해줘" 처럼 지시

> 이 저장소를 Git으로 관리한다면, **웹 Claude Code(claude.ai/code)** 로도 저장소를 열어 메모를 정리하고 커밋할 수 있습니다.

---

## 📱 방법 3) 아이폰 / 아이패드에서의 Claude

모바일에는 MCP 같은 직접 연동이 (아직) 없습니다. 현실적인 방법:

- **Claude 앱**에서 메모 내용을 복사해 붙여넣고 대화 → 결과를 옵시디언에 다시 붙여넣기
- 또는 **Mac에서 Claude로 정리 → iCloud 동기화** 되면 모바일에서 결과만 확인
- 옵시디언 모바일의 **"Text generator" / "Copilot" 커뮤니티 플러그인**에 Claude API 키를 넣어 앱 안에서 바로 AI 쓰기 (Anthropic API 키 필요)

> 정리·대량 작업은 **Mac에서**, 확인·간단 편집은 **모바일에서** — 이 역할 분담이 가장 매끄럽습니다.

---

## 🧪 잘 되는지 확인

방법 1을 마쳤다면 Claude에게 이렇게 물어보세요:

> "내 옵시디언 볼트의 00-Inbox 폴더에 있는 메모들을 읽고, 주제별로 요약해줘."

실제 메모 내용을 읽어서 답하면 연동 성공입니다. 🎉

---

## 🔒 보안 한마디

- Local REST API의 **API Key는 남에게 노출 금지** (설정 파일에만 보관)
- Anthropic API 키를 모바일 플러그인에 넣을 땐 신뢰할 수 있는 공식 플러그인만 사용

---

👉 다음: **[05-매일-사용법.md](05-매일-사용법.md)** — 이제 실제로 굴리는 법.
