# Windows(Parallels 가상머신) 자동 업데이트 → "알림만, 설치는 내가 결정"
#   적용:     관리자 PowerShell에서  powershell -ExecutionPolicy Bypass -File .\windows-disable-auto-update.ps1
#   되돌리기: 위 명령 끝에  -Undo
param([switch]$Undo)

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
  [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Write-Host "관리자 권한 PowerShell에서 실행하세요 (시작 → PowerShell 우클릭 → 관리자로 실행)" -ForegroundColor Red; exit 1 }

$WU    = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
$AU    = "$WU\AU"
$Store = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore'

if ($Undo) {
  Remove-Item $WU -Recurse -Force -ErrorAction SilentlyContinue
  Remove-ItemProperty $Store -Name AutoDownload -ErrorAction SilentlyContinue
  gpupdate /force | Out-Null
  Write-Host "✅ 자동 업데이트 정책을 제거했습니다 (Windows 기본값으로 복귀)." -ForegroundColor Green
  exit 0
}

New-Item $AU -Force | Out-Null
New-Item $Store -Force | Out-Null

# 2 = 업데이트가 있으면 '알림만' — 다운로드/설치는 사용자가 직접
Set-ItemProperty $AU -Name NoAutoUpdate -Type DWord -Value 0
Set-ItemProperty $AU -Name AUOptions    -Type DWord -Value 2
# 로그인 상태에서 자동 재시작 금지 (자동화 도중 재부팅 방지)
Set-ItemProperty $AU -Name NoAutoRebootWithLoggedOnUsers -Type DWord -Value 1
# Windows Update로 드라이버 자동 교체 금지 (Parallels 디스플레이·네트워크 드라이버 보호)
Set-ItemProperty $WU -Name ExcludeWUDriversInQualityUpdate -Type DWord -Value 1
# 다른 Microsoft 제품(Office 등) 자동 업데이트 끼워넣기 금지
Set-ItemProperty $AU -Name AllowMUUpdateService -Type DWord -Value 0
# Microsoft Store 앱 자동 업데이트 끔
Set-ItemProperty $Store -Name AutoDownload -Type DWord -Value 2

gpupdate /force | Out-Null

$ed = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').EditionID
Write-Host "✅ 완료. 이제 업데이트는 알림만 오고, '설정 → Windows 업데이트'에서 직접 눌러야 설치됩니다." -ForegroundColor Green
if ($ed -match 'Core') {
  Write-Host "⚠ Windows Home 에디션은 일부 정책을 무시할 수 있습니다. README의 '업데이트 일시 중지(5주)'도 함께 걸어 두세요." -ForegroundColor Yellow
}
