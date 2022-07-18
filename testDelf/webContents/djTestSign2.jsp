<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
    boolean isVeraPortCG = false;
    java.net.URL _clasUrl1 = this.getClass().getResource("/com/wizvera/crypto/pkcs7/PKCS7VerifyWithVpcg.class");
    java.net.URL _clasUrl2 = this.getClass().getResource("/com/wizvera/vpcg/VpcgSignResult.class");
    if (_clasUrl1 != null && _clasUrl2 != null) isVeraPortCG = true;
%>
<%
    String result_target = "testResult";
    String result_action = "/wizvera/delfino/demo/signResult.jsp";
    if (isVeraPortCG) result_action = "/wizvera/delfino/demo/signResultVpcg.jsp"; //통합인증 데모

    if ("on".equals(request.getParameter("debug"))) {
        result_target = "";
        result_action = "/wizvera/delfino/svc/delfino_checkResult.jsp?debug=on";
    }
    
    boolean addNonce = ("true".equals(request.getParameter("addNonce"))) ? true : false;
%>
<%@ include file="/wizvera/delfino/svc/delfino.jsp"%>
<%  //폼, form-urlencoding 전자서명에서 사용되는  format 값으로 세션에 저장 후 서명검증시 사용
    com.wizvera.service.util.KeyValueFormatter confirmFormatter = new com.wizvera.service.util.KeyValueFormatter();
    confirmFormatter.add("account", "출금계좌번호");
    confirmFormatter.add("recvBank", "입금은행");
    confirmFormatter.add("recvAccount", "입금계좌번호");
    confirmFormatter.add("recvUser", "받는분");
    confirmFormatter.add("amount", "이체금액");
    String confirmFormat = confirmFormatter.toString();
    session.setAttribute("TEST_confirmSign_form", confirmFormat);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>

<script type="text/javascript">
	var TEST_addNonce = <%=addNonce%>;
	if (TEST_addNonce && !DelfinoConfig.useNonceOption) alert("DelfinoConfig.useNonceOption set 'true'");

	//사용자확인 전자서명: 폼
	function TEST_confirmSign_form(signForm) {
		document.delfinoForm._action.value = "TEST_confirmSign_form";
	    var signOptions = {cacheCert:true};
	    
	    if(TEST_addNonce) signOptions.addNonce = true; //nonce값 추가하기
	    
	    var confirmFormat = "<%=confirmFormat%>";
	    
// 	    alert(typeof(confirmFormat));
// 	    alert(confirmFormat);
	    
	    Delfino.confirmSign(signForm, confirmFormat, signOptions, TEST_complete);
	}
	
	//전자서명시 호출되는  CallBack 함수
    var __result = null;
    function TEST_complete(result){
        __result = result;
        if(result.status==1){
            document.delfinoForm.PKCS7.value = result.signData;
            document.delfinoForm.VID_RANDOM.value = result.vidRandom;
            document.delfinoForm.submit();
        }
        else{
            if(result.status==0) return; //사용자취소
            if(result.status==-10301) return; //구동프로그램 설치를 위해 창을 닫을 경우
            //if (Delfino.isPasswordError(result.status)) alert("비밀번호 오류 횟수 초과됨"); //v1.1.6,0 over & DelfinoConfig.passwordError = true
            alert("error:" + result.message + "[" + result.status + "]");
        }
    }
</script>

<body>
	 <form name="delfinoForm" method="post" target="<%=result_target%>" action="<%=result_action%>">
        <input type="hidden" name="PKCS7" />
        <input type="hidden" name="VID_RANDOM" />
        <input type="hidden" name="addNonce" value="<%=addNonce%>" />
        <input type="hidden" name="_action" />
    </form>
	
    <h2>1. 포맷검증 전자서명</h2>
<!--     <form method="post" name="sign" action="signResult.jsp" onsubmit="TEST_confirmSign_form(this);return false;"> -->
    <form method="post" name="sign" action="signResult.jsp" onsubmit="TEST_confirmSign_form(this);return false;">
        <label>출금계좌</label><input type="text" name="account" value="111111-22-333333" />
        <label>입금은행</label><input type="text" name="recvBank" value="국민" />
        <br/>
        <label>입금계좌</label><input type="text" name="recvAccount" value="444444-55-666666" />
        <label>받는분</label><input type="text" name="recvUser" value="김모군" />
        <br/>
        <label>이체금액</label><input type="text" name="amount" value="10,000" />
        <label>기타</label><input type="text" name="etc" value="서명창표시되지않음" />
        <input type="submit" value="폼 전자서명" />
    </form>
    <br/>
    
</body>
</html>