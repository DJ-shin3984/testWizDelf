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
//     if (isVeraPortCG) result_action = "signResultVpcg.jsp"; //통합인증 데모
    if (isVeraPortCG) result_action = "/wizvera/delfino/demo/signResultVpcg.jsp"; //통합인증 데모

    if ("on".equals(request.getParameter("debug"))) {
        result_target = "";
        result_action = "/wizvera/delfino/svc/delfino_checkResult.jsp?debug=on";
    }
%>
<%@ include file="/wizvera/delfino/svc/delfino.jsp"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>

<script type="text/javascript">

	//인증서로그인: Delfio.login()
	function TEST_certLogin(){
	    document.delfinoForm._action.value = "TEST_certLogin";
	    document.delfinoForm.certStatusCheckType.value = document.inputForm.certStatusCheckType.value;

	    Delfino.login("login=certLogin", TEST_complete);
	    //Delfino.login("login=certLogin", TEST_complete, {serialNumberDecCertFilter:"448221515", certStoreFilter:"FINCERT"});
	    //Delfino.login("login=certLogin", TEST_complete, {serialNumberDecCertFilter:"448221515", certStoreFilter:"REMOVABLE_DISK"});
	    //Delfino.login("login=certLogin", {complete:TEST_complete_context, context:"sample certLogin context"});
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
            if(result.status==0) return; //사용자 취소
            if(result.status==-10301) return; //구동프로그램 설치를 위해 창을 닫을 경우
            //if (Delfino.isPasswordError(result.status)) alert("비밀번호 오류 횟수 초과됨"); //v1.1.6,0 over & DelfinoConfig.passwordError = true

            if(result.status==1000 || result.status==2000 || result.status==3000) {
                sample_VPCGUserMsgAlert(result);
                return;
            }
            alert("error:" + result.message + "[" + result.status + "]");
        }
    }
    
	//본인확인 로그인: Delfio.login()
	function TEST_vidLogin(){
	    if (Delfino.getModule() == "CG") {
	        alert("사설인증서는 주민번호를 이용한 본인확인 로그인을 할수 없습니다.");
	        return;
	    }
	    document.delfinoForm._action.value = "TEST_vidLogin";
	    document.delfinoForm.certStatusCheckType.value = document.inputForm.certStatusCheckType.value;
	    document.delfinoForm.idn.value = document.inputForm.idn.value;
	
	    Delfino.login("login=vidLogin", TEST_complete);
	}

</script>

<body>
	<form name="delfinoForm" method="post" target="<%=result_target%>" action="<%=result_action%>">
        <input type="hidden" name="PKCS7" />
        <input type="hidden" name="PKCS7_hex" />
        <input type="hidden" name="VID_RANDOM" />
        <input type="hidden" name="_action" />
        <input type="hidden" name="idn" />
        <input type="hidden" name="certStatusCheckType" />
    </form>
    
    <form name="inputForm">
        <input type="button" value="<%=((isVeraPortCG) ? "VID" : "본인확인")%>로그인" onclick="javascript:TEST_vidLogin();" />&nbsp;
        <span>주민번호<%=((isVeraPortCG) ? "/CI" : "(VID 체크용)")%></span> <input type="text" name="idn" value=""/>

        <span>유효성확인</span>
        <select name="certStatusCheckType">
	        <option value="NONE" selected="selected">NONE</option>
	        <option value="CRL">CRL</option>
	        <option value="OCSP">OCSP</option>
        </select><br/>
    </form>
    
	<a href="javascript:Delfino.manageCertificate();">인증서 관리</a><br>
	<hr/>
	<input type="button" id="moduleG10Login" value="G10" onclick="javascript:Delfino.setModule('G10');TEST_certLogin();" />
</body>
</html>