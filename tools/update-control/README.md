# ⏸ 자동 업데이트 끄기 — "묻고 나서, 내가 하라고 할 때만"

뉴서울 예약 등 자동화가 **Parallels / Windows / macOS 업데이트 → 재시작·드라이버 교체** 때문에 멈추는 걸 막습니다.
설정 후에는 업데이트가 **알림만** 오고, 직접 "지금 설치"를 눌러야 진행됩니다.

| 대상 | 방법 | 소요 |
|---|---|---|
| ① macOS + Parallels Tools | `mac-disable-auto-update.sh` (아이맥 터미널) | 1분 |
| ② Parallels Desktop 앱 | GUI 클릭 | 30초 |
| ③ Windows (가상머신 안) | `windows-disable-auto-update.ps1` (관리자 PowerShell) | 1분 |

---

## ① 아이맥 터미널

```bash
cd ~/볼트폴더/tools/update-control      # 이 폴더 위치로
sudo bash mac-disable-auto-update.sh
```

- macOS: 업데이트 **확인·알림은 유지**, 자동 다운로드/설치/재시작은 끔
- App Store 앱 자동 업데이트 끔
- 모든 가상머신의 **Parallels Tools 자동 업데이트** 끔

## ② Parallels Desktop 앱 자체 (GUI, 한 번만)

1. 메뉴 막대 **Parallels Desktop → 설정(Settings…) → 일반(General)**
2. **업데이트 확인(Check for updates)** → `매주` 또는 `수동` 
3. **자동으로 업데이트 다운로드(Download updates automatically)** → **체크 해제**

→ 새 버전이 나오면 알림만 뜨고, "설치"를 눌러야 업데이트됩니다.

> 스크립트에서 Parallels Tools 단계가 ⚠로 나오면(Standard 에디션 등):
> 가상머신 **구성(⚙) → 옵션 → 최적화(또는 기타)** → **"Parallels Tools 자동 업데이트"** 체크 해제

## ③ Windows (Parallels 가상머신 안에서)

1. 이 폴더의 `windows-disable-auto-update.ps1`을 Windows로 복사
   (Parallels 공유 폴더라면 Mac 경로가 `\\Mac\Home\...` 로 바로 보입니다)
2. **시작 → "PowerShell" 우클릭 → 관리자 권한으로 실행**
3. ```powershell
   powershell -ExecutionPolicy Bypass -File "\\Mac\Home\볼트폴더\tools\update-control\windows-disable-auto-update.ps1"
   ```

적용 내용:
- Windows Update → **"다운로드·설치 전에 알림"** (AUOptions=2)
- 로그인 상태에서 **자동 재부팅 금지**
- Windows Update로 **드라이버 자동 교체 금지** (Parallels 화면·네트워크 드라이버 보호)
- Microsoft Store 앱 자동 업데이트 끔

> **Windows Home 에디션**이라면 정책이 일부 무시될 수 있습니다. 추가로
> **설정 → Windows 업데이트 → 업데이트 일시 중지 → 5주** 를 걸어 두세요. (만료 전 알림이 오면 다시 연장)

---

## 업데이트하고 싶을 때 (내가 "진행해" 할 때)

1. 자동화 스크립트를 먼저 **중지**
2. Windows: **설정 → Windows 업데이트 → 업데이트 확인 → 설치**
   macOS: **시스템 설정 → 일반 → 소프트웨어 업데이트 → 지금 업데이트**
   Parallels: **Parallels Desktop → 업데이트 확인**
3. 재시작 후 자동화를 한 번 수동 실행해 정상 동작 확인 → 다시 켜기

## 원래대로 되돌리기

```bash
sudo bash mac-disable-auto-update.sh --undo
```
```powershell
powershell -ExecutionPolicy Bypass -File .\windows-disable-auto-update.ps1 -Undo
```

## 💡 함께 확인하면 좋은 것

자동화가 **Chrome/Edge + 셀레니움(웹드라이버)** 기반이라면, 브라우저가 혼자 업데이트되면서 드라이버 버전이 안 맞아 멈추는 경우도 흔합니다. 이 경우도 막고 싶으면 말씀해 주세요 — 브라우저 업데이트 정책도 같은 방식으로 추가해 드릴게요.
