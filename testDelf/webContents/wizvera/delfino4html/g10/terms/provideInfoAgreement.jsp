<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="ko" xml:lang="ko">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, width=device-width"/>
<title>제3자 정보제공 동의</title>
<style>
pre{
    padding:10px;
    overflow: auto;
    white-space: pre-wrap; /* pre tag내에 word wrap */
}
body {
    font-size: 12px;
    line-height: 24px;
    color: #373737;
}
</style>
</head>
<body>
<%@ include file="info.jsp" %>
<pre>
[제3자 정보제공 동의]

고객사명은 정보주체의 동의, 법률에 특별한 규정이 있는 경우 등 개인정보보호법 제17조 및 제18조에 해당하는 경우에만 개인정보를 제3자에게 제공합니다.

가. 용어의 정의
1. 연계정보(CI) : 특정 개인을 식별하기 위해 본인확인기관에서 생성한 암호화된 개인식별번호
2. 인증사업자 : "<%=providers%>" 등 전자서명 서비스를 제공하는 사업자

나. 제3자 제공에 관한 사항
1. 개인정보를 제공받는 자 : 인증사업자, 본인확인기관
2. 제공받는 자의 개인정보 이용목적 : 간편인증 시 본인확인 또는 전자서명
3. 제공하는 개인정보 항목 : 생년월일(로그인 시), 성명, 휴대폰번호
4. 제공받는 자의 보유 및 이용기간 : 본인확인 또는 전자서명 후 즉시 파기

위 개인정보의 제3자 제공 동의를 거부할 수 있습니다. 다만, 관련 [<%=serviceName%>] 이용 목적에 따른 서비스의 제한이 있을 수 있습니다.
</pre>
</body>
</html>

