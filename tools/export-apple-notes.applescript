-- ============================================================
-- 애플 메모(Apple Notes) → HTML + 매니페스트 내보내기
-- migrate.sh 가 이 스크립트를 호출합니다. 직접 실행할 필요 없어요.
-- 사용: osascript export-apple-notes.applescript <임시출력폴더>
-- ============================================================

on run argv
	set outDir to item 1 of argv

	-- 매니페스트: idx <TAB> 폴더 <TAB> 제목 <TAB> 생성일(YYYY-MM-DD)
	set manifest to ""
	set idx to 0

	tell application "Notes"
		set allNotes to notes
		repeat with n in allNotes
			set idx to idx + 1

			-- 제목
			try
				set noteTitle to name of n
			on error
				set noteTitle to "제목없음"
			end try

			-- 본문(HTML)
			try
				set noteHTML to body of n
			on error
				set noteHTML to ""
			end try

			-- 소속 폴더
			try
				set folderName to name of container of n
			on error
				set folderName to "Notes"
			end try

			-- 생성일 → YYYY-MM-DD
			try
				set d to creation date of n
				set y to (year of d) as integer
				set mo to (month of d as integer)
				set dy to (day of d) as integer
				set createdStr to (y as string) & "-" & my pad2(mo) & "-" & my pad2(dy)
			on error
				set createdStr to ""
			end try

			-- HTML을 개별 파일로 저장 (idx.html)
			set htmlPath to outDir & "/" & (idx as string) & ".html"
			my writeUTF8(htmlPath, noteHTML)

			-- 매니페스트 한 줄 (탭/개행은 공백으로 치환)
			set safeFolder to my clean(folderName)
			set safeTitle to my clean(noteTitle)
			set manifest to manifest & (idx as string) & tab & safeFolder & tab & safeTitle & tab & createdStr & linefeed
		end repeat
	end tell

	my writeUTF8(outDir & "/manifest.tsv", manifest)
	return (idx as string) & " notes exported"
end run

-- 두 자리 0 채우기
on pad2(n)
	set s to n as string
	if (count of s) < 2 then set s to "0" & s
	return s
end pad2

-- 탭·개행 제거(매니페스트 안전용)
on clean(t)
	set t to my replaceText(t, tab, " ")
	set t to my replaceText(t, linefeed, " ")
	set t to my replaceText(t, return, " ")
	return t
end clean

on replaceText(theText, findStr, replaceStr)
	set AppleScript's text item delimiters to findStr
	set parts to text items of theText
	set AppleScript's text item delimiters to replaceStr
	set out to parts as string
	set AppleScript's text item delimiters to ""
	return out
end replaceText

-- UTF-8로 파일 쓰기
on writeUTF8(posixPath, theText)
	set f to open for access (POSIX file posixPath) with write permission
	set eof of f to 0
	write theText to f as «class utf8»
	close access f
end writeUTF8
