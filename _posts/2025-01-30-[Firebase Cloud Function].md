---
title: "[Firebase] cloud functions"
tags: 
- Firebase
use_math: true
header: 
  teaser: /assets/img/Swift/SwiftWhite.png
---

# Cloud Functions
- Cloud Functions는 Firebase의 기능과 HTTP 요청에 의해서 Trigger 되는 이벤트에 응답하여 백엔드 코드를 자동으로 실행시켜주는 서버리스 프레임워크

## ✅ 1. Firebase Cloud Functions 설정
- 먼저 Firebase CLI를 설치하고 프로젝트에 Cloud Functions를 추가  

```bash
# Firebase CLI 설치 (설치 안 되어 있다면)
brew install firebase-cli

# 설치가 끝나면 아래 명령어로 정상적으로 설치되었는지 확인
firebase --version

# Firebase 로그인
firebase login

# Firebase Functions 초기화
firebase init functions

# 환경변수 추가 (필요할 경우)
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```  

## ✅ 2. (Gmail + Nodemailer 사용)
- Google 앱 비밀번호에서 비밀번호를 생성
- Gmail -> 설정 -> 전달 및 POP/IMAP -> IMAP 사용


## ✅ 3. Cloud Functions 코드 작성 (index.js)
- Gmail + Nodemailer를 활용
- ✅ 닉네임이 처음 생성될 때만 이메일 전송 + 구글 시트 추가
- ✅ 닉네임이 변경되거나 다른 정보가 변경될 경우, 이메일 없이 시트만 업데이트
- ✅ 유저가 삭제되면 '탈퇴'로 표시  

```javascript
const { onValueUpdated, onValueDeleted } = require("firebase-functions/v2/database");
const admin = require("firebase-admin");
const { google } = require("googleapis");
const nodemailer = require("nodemailer");

admin.initializeApp();

// ✅ Gmail 설정 (앱 비밀번호 사용)
const GMAIL_EMAIL = "indextrown@gmail.com";
const GMAIL_PASSWORD = "";

// ✅ Nodemailer 설정
const transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 465,
    secure: true,
    auth: {
        user: GMAIL_EMAIL,
        pass: GMAIL_PASSWORD
    },
    tls: {
        rejectUnauthorized: false
    }
});

// ✅ Google Sheets API 설정
const SHEET_ID = "";
const SCOPES = ["https://www.googleapis.com/auth/spreadsheets"];
const keyFilePath = "/workspace/codeloungeusers-a47a950f7b06.json";

async function getGoogleSheetsClient() {
    const auth = new google.auth.GoogleAuth({
        keyFile: keyFilePath,
        scopes: SCOPES
    });
    return google.sheets({ version: "v4", auth });
}

// ✅ 유저 정보를 구글 시트에 업데이트 (닉네임 변경 시 이메일 전송 X)
async function updateUserInGoogleSheet(userData) {
    try {
        const sheets = await getGoogleSheetsClient();
        
        const readRes = await sheets.spreadsheets.values.get({
            spreadsheetId: SHEET_ID,
            range: "Users!A:G"
        });

        let values = readRes.data.values || [];
        let userRowIndex = values.findIndex(row => row[1] === userData.id);

        if (userRowIndex !== -1) {
            // ✅ 기존 행 업데이트
            values[userRowIndex] = [
                userData.nickname,
                userData.id,
                userData.loginPlatform,
                userData.gender,
                userData.birthdayDate,
                userData.registerDate,
                "" // 탈퇴 여부 비움
            ];

            await sheets.spreadsheets.values.update({
                spreadsheetId: SHEET_ID,
                range: `Users!A${userRowIndex + 1}:G${userRowIndex + 1}`,
                valueInputOption: "RAW",
                resource: { values: [values[userRowIndex]] }
            });
            console.log(`✅ 구글 시트 업데이트 완료: ${userData.id}`);
        } else {
            console.log(`⚠️ 업데이트할 유저를 찾을 수 없음: ${userData.id}`);
        }
    } catch (error) {
        console.error("❌ 구글 시트 업데이트 오류:", error);
    }
}

// ✅ 유저가 처음 닉네임을 설정할 때 이메일 전송 & 시트에 추가
async function addUserToGoogleSheet(userData) {
    try {
        const sheets = await getGoogleSheetsClient();

        await sheets.spreadsheets.values.append({
            spreadsheetId: SHEET_ID,
            range: "Users!A:G",
            valueInputOption: "RAW",
            resource: { values: [[
                userData.nickname,
                userData.id,
                userData.loginPlatform,
                userData.gender,
                userData.birthdayDate,
                userData.registerDate,
                "" // 신규 가입이므로 탈퇴 X
            ]] }
        });
        console.log(`✅ 새로운 유저 추가: ${userData.id}`);

        // ✅ 관리자에게 이메일 전송
        const mailOptions = {
            from: GMAIL_EMAIL,
            to: "indextrown@gmail.com",
            subject: "[코드라운지] 새 사용자가 가입했습니다.",
            text: `📢 새 사용자 정보:
닉네임: ${userData.nickname}
ID: ${userData.id}
플랫폼: ${userData.loginPlatform}
성별: ${userData.gender}
생일: ${userData.birthdayDate}
가입 날짜: ${userData.registerDate}`
        };

        await transporter.sendMail(mailOptions);
        console.log("✅ 관리자에게 메일 전송 성공!");
    } catch (error) {
        console.error("❌ 유저 추가 오류:", error);
    }
}

// ✅ 유저 삭제 감지 → 구글 시트에서 "탈퇴"로 표시
async function markUserAsDeleted(userId) {
    try {
        const sheets = await getGoogleSheetsClient();
        
        const readRes = await sheets.spreadsheets.values.get({
            spreadsheetId: SHEET_ID,
            range: "Users!A:G"
        });

        let values = readRes.data.values || [];
        let userRowIndex = values.findIndex(row => row[1] === userId);

        if (userRowIndex !== -1) {
            values[userRowIndex][6] = "탈퇴"; 

            await sheets.spreadsheets.values.update({
                spreadsheetId: SHEET_ID,
                range: `Users!A${userRowIndex + 1}:G${userRowIndex + 1}`,
                valueInputOption: "RAW",
                resource: { values: [values[userRowIndex]] }
            });
            console.log(`🚨 유저 삭제 감지 - 탈퇴 처리 완료: ${userId}`);
        } else {
            console.log(`⚠️ 삭제된 유저를 찾을 수 없음: ${userId}`);
        }
    } catch (error) {
        console.error("❌ 구글 시트 탈퇴 처리 오류:", error);
    }
}

// ✅ 닉네임이 처음 생성될 때만 이메일 전송 & 시트 추가
exports.addNewUser = onValueUpdated("/Users/{userId}", async (event) => {
    const beforeData = event.data.before.val();
    const afterData = event.data.after.val();

    if (!afterData) return console.error("❌ 오류: 데이터 없음");

    // ✅ 닉네임이 처음 설정될 때만 이메일 발송
    if ((!beforeData || !beforeData.nickname) && afterData.nickname) {
        console.log(`📢 새로운 닉네임 생성 감지: ${afterData.nickname}`);
        await addUserToGoogleSheet(afterData);
    } else {
        console.log(`ℹ️ 기존 유저 정보 업데이트 감지: ${afterData.id}`);
        await updateUserInGoogleSheet(afterData);
    }
});

// ✅ 유저 삭제 감지 (삭제되면 "탈퇴"로 업데이트)
exports.markUserDeletedInSheet = onValueDeleted("/Users/{userId}", async (event) => {
    const userId = event.params.userId;
    console.log(`🚨 유저 삭제 감지: ${userId}`);

    await markUserAsDeleted(userId);
});
```

## ✅ 4. 버전 문제 해결
- firebase --version
- npm list firebase-functions

```bash
functions@ /Users/kimdonghyeon/functions
└── firebase-functions@4.3.0
// firebase-functions@4.3.0이면 2nd Gen (v4.x) 사용 중
// firebase-functions@3.26.0이면 1st Gen (v3.x) 사용 중
```

## ✅ 5. 구글 스프레드 시트
## 5-1 
- googleapis 모듈 설치 필요
```bash
# nvm을 사용하여 Node.js 22로 변경
brew install nvm

# 터미널 재시작 후 Node.js 22 설치
nvm install 22

# Node.js 22로 버전 변경
nvm use 22

# 현재 버전 확인
node -v

# googleapis 설치
npm install googleapis

```


- 📌 Firebase 환경 변수에 JSON 키 저장
```bash
firebase functions:config:set google_sheets.service_account_json="$(cat service-account.json)"
```
- ⚠️ Firebase 환경 변수 업데이트 후 Functions를 다시 배포해야 함
```bash
firebase deploy --only functions
```
- 📌 설정이 정상적으로 저장되었는지 확인하는 방법:
```bash
firebase functions:config:get
```

## ✅ 6. 구글 시트 연동 및 api(json)발급은 아래 링크 참고
- https://velog.io/@junsugi/Google-Sheet-연동하기-feat.-Google-API