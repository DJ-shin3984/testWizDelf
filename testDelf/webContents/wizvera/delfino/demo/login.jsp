<%-- --------------------------------------------------------------------------
 - File Name   : login.jsp(로그인 샘플)
 - Include     : delfino.jsp
 - Author      : WIZVERA
 - Last Update : 2022/04/28
-------------------------------------------------------------------------- --%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    java.text.DateFormat logDate = new java.text.SimpleDateFormat("[yyyy/MM/dd HH:mm:ss] ");
    System.out.println(logDate.format(new java.util.Date())+request.getRequestURI()+" "+request.getMethod()+"[" + request.getRemoteAddr() + "]");
%>
<%
    boolean isVeraPortCG = false;
    java.net.URL _clasUrl1 = this.getClass().getResource("/com/wizvera/crypto/pkcs7/PKCS7VerifyWithVpcg.class");
    java.net.URL _clasUrl2 = this.getClass().getResource("/com/wizvera/vpcg/VpcgSignResult.class");
    if (_clasUrl1 != null && _clasUrl2 != null) isVeraPortCG = true;
%>
<%
    String result_target = "testResult";
    String result_action = "signResult.jsp";
    if (isVeraPortCG) result_action = "signResultVpcg.jsp"; //통합인증 데모

    if ("on".equals(request.getParameter("debug"))) {
        result_target = "";
        result_action = "../svc/delfino_checkResult.jsp?debug=on";
    }
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ko" xml:lang="ko">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta http-equiv="Expires" content="-1" />
    <meta http-equiv="Progma" content="no-cache" />
    <meta http-equiv="cache-control" content="no-cache" />
<%
    if ("on".equals(session.getAttribute("delfino_mobile_demo"))) {
        out.println("    <meta name='viewport' content='initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, width=device-width' />");
    }
%>
    <title>WizIN-Delfino Sample</title>

    <%@ include file="../svc/delfino.jsp"%>

</head>

<body>
    <h1>로그인/본인확인 <font size=2><a href="./index.jsp">home</a></font></h1>
    <font size="2">유효기간이 만기된 인증서와 운영 또는 개발용 인증서는 보이지 않습니다.
        <a href="javascript:Delfino.setPolicyOidCertFilter('');Delfino.setIssuerCertFilter('');alert('인증서필터링이 제거되엇습니다.');">인증서필터링해제</a>
        <a href="javascript:TEST_pkcs7('');">test</a>

        <br/> 정상적으로 보이지 않으면 인증서관리에서 인증서가 있는지 확인하시기 바랍니다
        <a href="javascript:Delfino.manageCertificate();">인증서관리</a>
        <a href='javascript:Delfino.resetRecentModule();location.reload();'>reload</a>

        <br/> 중계서버를 이용하여 인증서를 타 기기로 이동할수 있습니다.
        <a href="javascript:TEST_exportCertificate();">인증서내보내기</a>
        <a href='javascript:TEST_importCertificate();'>인증서가져오기</a>
    </font>

    <script type="text/javascript">
    //<![CDATA[

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

    //VeraPort-CG APP전용: 핀테크연동관련 오류처리 샘플
    //result = JSON.parse(resultString); //앱에서 전달받은 JSON포맷된 스트링
    //status: 0, 1이 아닐 경우 고객출력용 메시지 샘플
    function sample_VPCGUserMsgAlert(result) {
        var status = result.status;
        var message = result.message;
        var userMsg = "통합인증이 정상적으로 처리되지 않았습니다.[" + status + "]\n" + message;

        var code = "XXXX";
        var provider = "vpcg";
        if (result.error) {
            code = result.error.code;
            provider = result.error.provider;
            message = result.error.message;
        }
        if (typeof(provider) == "undefined") {
            alert("provider is undefined");
            provider = "vpcg";
        }
        if (status == 1000) {
            userMsg = "통합인증이 정상적으로 처리되지 않았습니다(Unknown). 다시 시도해 주세요"; //default
            if (code == "1001") {
                userMsg = "통합인증이 정상적으로 처리되지 않았습니다(Unknown). 다시 시도해 주세요";
            } else if (code == "1002") {
                userMsg = "통합인증이 정상적으로 처리되지 않았습니다(NotSupportEncoding). 다시 시도해 주세요";
            } else if (code == "1003") {
                userMsg = "통합인증이 정상적으로 처리되지 않았습니다(MakeSignResultFail). 다시 시도해 주세요";
            } else if (code == "1004") {
                userMsg = "통합인증이 정상적으로 처리되지 않았습니다(CallAppFail). 다시 시도해 주세요";
            } else if (code == "1005") {
                userMsg = "인증요청이 취소 되었습니다(" + provider + "). 다시 한번 시도해주세요";
            } else if (code == "1006") {
                userMsg = "인증요청이 정상적으로 실행되지 않았습니다(rawResponse). 다시 한번 시도해주세요";
            } else if (code == "1007") {
                userMsg = "통합인증이 정상적으로 처리되지 않았습니다(NotExistSignAppIntent). 다시 시도해 주세요";
            } else if (code == "1008") {
                userMsg = "통합인증이 정상적으로 처리되지 않았습니다(EmptyProviders). 다시 시도해 주세요";
            } else if (code == "1009") {
                userMsg = "통합인증에 필요한 서명앱(" + provider + ")이 설치되어 있지 않습니다.";
            } else if (code == "1010") {
                userMsg = "인증요청이 정상적으로 처리되지 않았습니다(SignDataLimited). 다시 시도해 주세요";
            } else if (code == "1102") {
                userMsg = "인증요청이 정상적으로 처리되지 않았습니다(ParseFail). 다시 시도해 주세요";
            }
            userMsg += "[" + provider.toUpperCase() + "-" + code + "]"; //프로바이드 및 에러코드 추가
        }
        else if (status == 2000) {
            userMsg = "통합인증 서비스가 정상적으로 처리되지 않았습니다(http). 잠시 후 다시 한번 거래해 주시기 바랍니다."; //default
            if (code == "invalid_request") {
                userMsg = "통합인증 서비스가 정상적으로 처리되지 않았습니다(param), 잠시후 다시 한번 거래해 주시기 바랍니다.";
            } else if (code == "server_error") {
                userMsg = "통합인증 서비스가 정상적으로 처리되지 않았습니다(internal), 잠시후 다시 한번 거래해 주시기 바랍니다.";
            } else if (code == "network_error") {
                userMsg = "인증서버(" + provider + ") 접속이 지연되고 있습니다. 잠시 후 다시 한번 거래해 주시기 바랍니다.";
            } else if (code == "decrypt_error") {
                userMsg = "통합인증 서비스가 정상적으로 처리되지 않았습니다(decrypt), 잠시후 다시 한번 거래해 주시기 바랍니다.";
            } else if (code == "2300") {
                userMsg = "통합인증 서비스가 정상적으로 처리되지 않았습니다(agent), 잠시후 다시 한번 거래해 주시기 바랍니다.";
            } else if (code == "2301") {
                userMsg = "통합인증서버 접속이 지연되고 있습니다(agent). 잠시 후 다시 한번 거래해 주시기 바랍니다.";
            }
            userMsg += "[" + provider.toUpperCase() + "-" + code + "]"; //프로바이드 및 에러코드 추가
        }
        else if (status == 3000) {
            userMsg = "통합인증요청에 실패하였습니다.";
            userMsg += "[" + provider.toUpperCase() + "-" + code + "]"; //프로바이드 및 에러코드 추가
            userMsg += "\n- " + message; //인증업체에서 전달받은 메시지 출력
        }
        alert(userMsg);
    }

    function TEST_complete_context(result, context){
        alert(context);
        TEST_complete(result);
    }

    //인증서로그인: Delfio.login()
    function TEST_certLogin(){
        document.delfinoForm._action.value = "TEST_certLogin";
        document.delfinoForm.certStatusCheckType.value = document.inputForm.certStatusCheckType.value;

        Delfino.login("login=certLogin", TEST_complete);
        //Delfino.login("login=certLogin", TEST_complete, {serialNumberDecCertFilter:"448221515", certStoreFilter:"FINCERT"});
        //Delfino.login("login=certLogin", TEST_complete, {serialNumberDecCertFilter:"448221515", certStoreFilter:"REMOVABLE_DISK"});
        //Delfino.login("login=certLogin", {complete:TEST_complete_context, context:"sample certLogin context"});
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

    //인증서등록: Delfio.auth2()
    function TEST_registerCert(){
        document.delfinoForm._action.value = "TEST_registerCert";
        document.delfinoForm.certStatusCheckType.value = document.inputForm.certStatusCheckType.value;
        document.delfinoForm.idn.value = document.inputForm.idn.value;

        var signOptions = {};
        signOptions.provider = document.inputForm.selectProvider.value;
        signOptions.displayProviders = document.inputForm.selectProvider.value;

        //CI 또는 userInfo를 이용한 인증요청 샘플
        if (document.inputForm.idn.value != "") {
            if ("kakao" == signOptions.provider || "toss" == signOptions.provider || "payco" == signOptions.provider) {
                signOptions.userCi = document.inputForm.idn.value;
                alert("input CI:" + signOptions.userCi);
            } else {
                alert("CI를 이용한 인증요청은 카카오(S3x0)과 토스/페이코인증만 지원합니다.");
            }
        } else {
            var cgUserInfo = {};
            cgUserInfo.userName = "홍길동";
            cgUserInfo.userPhone = "01012345678";
            cgUserInfo.userBirthday = "20211231";
            //signOptions.userInfo = cgUserInfo;
        }

        Delfino.auth2("login=registerCert", signOptions, TEST_complete);
    }

    //인증서중계: 가져오기/내보내기
    function TEST_importCertificate(){
        Delfino.importCertificate(TEST_completeImport); //인증서가져오기
    }
    function TEST_exportCertificate(){
        Delfino.exportCertificate(TEST_completeExport); //인증서내보내기
        //Delfino.exportCertificate({disableExpireFilter:true}, TEST_completeExport); //만료된 인증서 보이기
    }
    function TEST_completeImport(result) {
        if(result.status==0) {
            alert("가져오기 취소"); //사용자취소
        } else if(result.status==1) {
            alert("가져오기 성공");
        } else {
            alert(result.message + "[" + result.status + "]");
        }
    }
    function TEST_completeExport(result) {
        if(result.status==0) {
            alert("내보내기 취소"); //사용자취소
        } else if(result.status==1) {
            alert("내보내기 성공");
        } else {
            alert(result.message + "[" + result.status + "]");
        }
    }

    //]]>
    </script>

    <form name="delfinoForm" method="post" target="<%=result_target%>" action="<%=result_action%>">
        <input type="hidden" name="PKCS7" />
        <input type="hidden" name="PKCS7_hex" />
        <input type="hidden" name="VID_RANDOM" />
        <input type="hidden" name="_action" />
        <input type="hidden" name="idn" />
        <input type="hidden" name="certStatusCheckType" />
    </form>

    <div id="module_default" style="display:block;">
    <h2>1. 인증서로그인 <font size=2>(서버에 인증서에 매칭되는 사용자정보가 있을경우)</font></h2>
        <input type="button" value="인증서로그인" onclick="javascript:TEST_certLogin();" />
    </div>

    <!-- 모듈캐쉬기능 사용시 샘플/START -->
    <div id="module_cache" style="display:none;">
    <h2>1. 인증서로그인 <font size=2>(서버에 인증서에 매칭되는 사용자정보가 있을경우)</font></h2>
        <input type="button" id="moduleLogin" value="인증서로그인" onclick="javascript:Delfino.setModule(DelfinoConfig.module);TEST_certLogin();" />
        &nbsp;&nbsp;
        <input type="button" id="moduleG2Login" value="G2" onclick="javascript:Delfino.setModule('G2');TEST_certLogin();" />
        <input type="button" id="moduleG3Login" value="G3" onclick="javascript:Delfino.setModule('G3');TEST_certLogin();" />
        <input type="button" id="moduleG4Login" value="G4" onclick="javascript:Delfino.setModule('G4');TEST_certLogin();" />
        <input type="button" id="moduleG10Login" value="G10" onclick="javascript:Delfino.setModule('G10');TEST_certLogin();" />
        &nbsp;&nbsp;
        <input type="button" id="moduleG5Login" value="G5" onclick="javascript:Delfino.setModule('G5');TEST_certLogin();" style="display:none;" />
        <input type="button" id="moduleEALogin" value="EA" onclick="javascript:Delfino.setModule('EA');TEST_certLogin();" style="display:none;" />
        (로그인시 모듈 지정 및 이체시는 캐쉬된 모듈 사용)
    </div>
    <script type="text/javascript">
    function init_DemoLogin() {
        Delfino.resetRecentModule(); Delfino.setModule();
        //if (!DC_platformInfo.Mobile) { Delfino.resetRecentModule(); Delfino.setModule(); }
        if (DelfinoConfig.useRecentModule) {
            document.getElementById("module_default").style.display = "none";
            document.getElementById("module_cache").style.display = "block";
            document.getElementById("moduleLogin").value="인증서로그인(설정값:" + DelfinoConfig.module + ")";
            if (DC_platformInfo.Mobile) {
                document.getElementById("moduleG2Login").disabled = true;
                document.getElementById("moduleG3Login").disabled = true;
            }
            if (!Delfino.isSupportedG4()) {
                document.getElementById("moduleG4Login").disabled = true;
                document.getElementById("moduleG4Login").value="G4(미지원)";
                //if (DelfinoConfig.module == "G4") document.getElementById("moduleLogin").disabled = true;
            }
            if (!Delfino.isSupportedG10()) {
                document.getElementById("moduleG10Login").disabled = true;
                document.getElementById("moduleG10Login").value="G10(미지원)";
                //if (DelfinoConfig.module == "G10") document.getElementById("moduleLogin").disabled = true;
            }

            //G5
            if (typeof(DelfinoConfig.g5) == "object") {
                document.getElementById("moduleG5Login").style.display = "";
                if (!Delfino.isSupportedG5()) {
                    document.getElementById("moduleG5Login").disabled = true;
                    document.getElementById("moduleG5Login").value="G5(미지원)";
                }
            }

            //간편인증(CertGate)
            if (!Delfino.isSupportedEA()){
                document.getElementById("moduleEALogin").disabled = true;
                document.getElementById("moduleEALogin").value="EA(미지원)";
            }
            if (window.EA && ('object' === typeof window.EA)) {
                document.getElementById("moduleEALogin").style.display = "";
            }
        }
    }
    if (typeof Delfino != "undefined") {
        init_DemoLogin();
    } else {
        window.onload= function() {
            try { init_DemoLogin(); } catch (err) { alert("init_DemoLogin: " + err); }
        };
    }
    </script>
    <!-- 모듈캐쉬기능 사용시 샘플/END -->


    <h2>2. 본인확인 로그인 <font size=2>(서버에 인증서에 매칭되는 사용자정보가 없을경우)</font></h2>

    <form name="inputForm">
        <input type="button" value="<%=((isVeraPortCG) ? "VID" : "본인확인")%>로그인" onclick="javascript:TEST_vidLogin();" />&nbsp;

<% if (isVeraPortCG) { %>
        <input type="button" value="인증서등록" onclick="javascript:TEST_registerCert();" />
        <select name="selectProvider">
          <option selected value="">default</option>
          <option value="kakao">kakao</option>
          <option value="kakaotalk">kakaotalk</option>
          <option value="naver2">naver2</option>
          <option value="toss">toss</option>
          <option value="pass">pass</option>
          <option value="payco">payco</option>
          <option value="fincert">fincert</option>
          <option value="fincertcorp">fincertC</option>
          <option value="delfino">delfino</option>
        </select>
<% } %>

        <span>주민번호<%=((isVeraPortCG) ? "/CI" : "(VID 체크용)")%></span> <input type="text" name="idn" value=""/>
        <span>유효성확인</span>
        <select name="certStatusCheckType">
          <option value="NONE" selected="selected">NONE</option>
          <option value="CRL">CRL</option>
          <option value="OCSP">OCSP</option>
        </select><br/>
    </form>

    <hr/>
    <h2>Result <font size=2>[<%=result_action%>] [<a href="./sign.jsp">sign</a>]&nbsp;&nbsp;&nbsp;
      [
       <a href="javascript:TEST_pkcs7('NPKI');">NPKI</a> <a href="javascript:TEST_pkcs7('GPKI');">GPKI</a>
       <a href="javascript:TEST_pkcs7('yessR');">yessR</a> <a href="javascript:TEST_pkcs7('yessT');">yessT</a>
      ]
      [
       <a href="javascript:TEST_pkcs7('kakao');">kakao</a> <a href="javascript:TEST_pkcs7('kakaotalk');">kakaotalk</a>
       <a href="javascript:TEST_pkcs7('toss');">toss</a> <a href="javascript:TEST_pkcs7('naver2');">naver2</a> <a href="javascript:TEST_pkcs7('naver');">naver</a>
       <a href="javascript:TEST_pkcs7('pass');">pass</a> <a href="javascript:TEST_pkcs7('payco');">payco</a>
      ]
    </font></h2>
    <table width="100%" border="1" align="center" cellpadding="0" cellspacing="0">
      <tr><td bgcolor="#FFFFFF" height="350">
        <iframe name='testResult' id='testResult' frameborder='0' width='100%' height='100%' src='<%=result_action%>?_action=TEST_TEST'></iframe>
      </td></tr>
    </table>

    <script type="text/javascript">
    function TEST_pkcs7(provider, authType){
        var pkcs7_npkiT = "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";
        var pkcs7_npkiR = "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";
        var pkcs7_gpkiR = "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";
        var pkcs7_yessT = "MIIImAYJKoZIhvcNAQcCoIIIiTCCCIUCAQExDzANBglghkgBZQMEAgEFADBqBgkqhkiG9w0BBwGgXQRbbG9naW49Y2VydExvZ2luJmRlbGZpbm9Ob25jZT1IaXBtODFnU084U1BvUmxwbDU2NjlqS1BCVkklM0QmX19DRVJUX1NUT1JFX01FRElBX1RZUEU9RklOQ0VSVKCCBdYwggXSMIIEuqADAgECAgNI3O0wDQYJKoZIhvcNAQELBQAwVzELMAkGA1UEBhMCa3IxEDAOBgNVBAoMB3llc3NpZ24xFTATBgNVBAsMDEFjY3JlZGl0ZWRDQTEfMB0GA1UEAwwWeWVzc2lnbkNBLVRlc3QgQ2xhc3MgNTAeFw0yMjA0MjQxNTAwMDBaFw0yMjA1MjUxNDU5NTlaMHAxCzAJBgNVBAYTAmtyMRAwDgYDVQQKDAd5ZXNzaWduMRIwEAYDVQQLDAlwZXJzb25hbEYxDTALBgNVBAsMBEtGVEMxLDAqBgNVBAMMI-q5gOyDgeq3oChURVNUKTAwOTkxNjgyMDIyMDQyNTAwMDMzMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAviAlbwJz3V7iGc1jfGw8nkamx8S_W7tfhHkVqLlR0vCkGSJVxQ-AbZP7rgjvqXg7OOBt2p3QcB51yG6SX1lfqMMEJ63thPzpaszUtaqKbP9bE72fWHABF1fZRU9ice79hUenhK1dKzeFbdbimyEumYeyrpp7-K6UQOejaDvR_UFU4-8WNfaHbKAJDr0q_p35vuG9z9Nc6ev8ChvhzotiiPBmfSy4m6Xcd5hovxppNXhiXhpxgewPAnVnvJNiykBrE_3zz6pWxS1J7eEmDJc7JpmBKNHVX4H2bIoatkHoQMdn8qTnAiMh85zyglE8eUjKhpD2yulJnUAraCIroJU-twIDAQABo4ICjDCCAogwgZMGA1UdIwSBizCBiIAUo9U5NjEVNk-yUcDaCDszeIEwz4-hbaRrMGkxCzAJBgNVBAYTAktSMQ0wCwYDVQQKDARLSVNBMS4wLAYDVQQLDCVLb3JlYSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eSBDZW50cmFsMRswGQYDVQQDDBJLaXNhIFRlc3QgUm9vdENBIDeCARkwHQYDVR0OBBYEFGHwyVJSHMbqmTFTs8_lawxAdnRGMA4GA1UdDwEB_wQEAwIGwDCBmgYDVR0gAQH_BIGPMIGMMIGJBgoqgxqMmkUBAQEKMHswSAYIKwYBBQUHAgIwPB46x3QAIMd4yZ3BHLKUACCuCMc1rLDIHMbQxdDBHAAgvByuCdVcACDC3NXYxqkAIMd4yZ3BHMeFssiy5DAvBggrBgEFBQcCARYjaHR0cDovL3Nub29weS55ZXNzaWduLm9yLmtyL2Nwcy5odG0waAYDVR0RBGEwX6BdBgkqgxqMmkQKAQGgUDBODAnquYDsg4Hqt6AwQTA_BgoqgxqMmkQKAQEBMDEwCwYJYIZIAWUDBAIBoCIEIOTfC2t1DVEzcetrceQyfhz7_dCHbsT7m87mPoTX54eEMHoGA1UdHwRzMHEwb6BtoGuGaWxkYXA6Ly9zbm9vcHkueWVzc2lnbi5vci5rcjoxNjAyMC9vdT1kcDEwMDAzcDI1NixvdT1BY2NyZWRpdGVkQ0Esbz15ZXNzaWduLGM9a3I_Y2VydGlmaWNhdGVSZXZvY2F0aW9uTGlzdDA-BggrBgEFBQcBAQQyMDAwLgYIKwYBBQUHMAGGImh0dHA6Ly9vY3NwdGVzdC55ZXNzaWduLm9yLmtyOjQ2MTIwDQYJKoZIhvcNAQELBQADggEBAHS_SebHoyiigxyTxZiD-_9O1LP9QIzkb6f7z3697BtJD6pLYCZJHjN4tohqjRwlz6wjlpVH8FPpuvumg3zOvPtqnq-FIdBOQSx-saERcOS2l7s7j0QO_VHu4bwxyvZLi7wtOC1I-XcSUGw2gK2MR1wLPHKvXq6E95QbssqF3vVqHVUScSuqRt7njGwtXIDxuwjHwfSl9k_fu--lCEapMbBztmhUg8k1dJnwwj3683uOEcQiph0NuHWtLGmdQFa_Qr1YsjCfp2TqA7VujLhLWQpA3qtwvaA3tut8rLGSIbA-BING8CvQaRYCNwJc1dx37SDTcjAxLcJGkpGDWnr5jocxggInMIICIwIBATBeMFcxCzAJBgNVBAYTAmtyMRAwDgYDVQQKDAd5ZXNzaWduMRUwEwYDVQQLDAxBY2NyZWRpdGVkQ0ExHzAdBgNVBAMMFnllc3NpZ25DQS1UZXN0IENsYXNzIDUCA0jc7TANBglghkgBZQMEAgEFAKBpMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIyMDQyNTA1NTQ0MlowLwYJKoZIhvcNAQkEMSIEIFuijwaRe0oIJOUBZuCnRlWsewFDHtqnHWj0biALp_K3MA0GCSqGSIb3DQEBAQUABIIBAIqhFekh-pvbhyatCAdFOM8Nrh0_A6O5eteNN73aiPm9MMqlioz8oLnsgKRywYYA72x5Tu0EW4g98Hr9LVyVHZOVOlFIH-5t5ppXLhab-U2fg8rboxPoRjwAHKaZYtUEwqjtcCe17npTM4nmiS3Amz8EFV4XuMaJHiocf0hrHIFViQXNinNcu_y9RjQlxVArKClXO7GBeNEqxEOKdly3GvRNxLHbqTc8lvfTX3GmKicagI5SgLPSv6ktMJ9s524JSxfnjCanKVfJw4M6Y6eH4885tCvzOv3kwmMBnXDWM6ICMcgchrLqhkqyTjl0pUPsgBzFVbBxmeHTmI76qCNXsRChMTAvBgkqgxqMmkUBCgExIgQgMB4TBWR1bW15AxUAKyZ06m0KGP5jiuiGhLAEri0ejv0";
        var pkcs7_yessR = "MIIIfwYJKoZIhvcNAQcCoIIIcDCCCGwCAQExDzANBglghkgBZQMEAgEFADByBgkqhkiG9w0BBwGgZQRjbG9naW49Y2VydExvZ2luJmRlbGZpbm9Ob25jZT0lMkJ1SUFEJTJCTVolMkJ4anBCRHlaMDRIZmFUJTJGdEVNVSUzRCZfX0NFUlRfU1RPUkVfTUVESUFfVFlQRT1GSU5DRVJUoIIFuTCCBbUwggSdoAMCAQICBCkgSzkwDQYJKoZIhvcNAQELBQAwUjELMAkGA1UEBhMCa3IxEDAOBgNVBAoMB3llc3NpZ24xFTATBgNVBAsMDEFjY3JlZGl0ZWRDQTEaMBgGA1UEAwwReWVzc2lnbkNBIENsYXNzIDIwHhcNMjAxMjAyMTUwMDAwWhcNMjMxMjAzMTQ1OTU5WjBvMQswCQYDVQQGEwJrcjEQMA4GA1UECgwHeWVzc2lnbjESMBAGA1UECwwJcGVyc29uYWxGMQwwCgYDVQQLDANER0IxLDAqBgNVBAMMI-q5gOyDgeq3oCgpMDAzMTE2ODIwMjAxMjAzMTMxMDAxMDQ2MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnP0zc1cbEXagd3rTO9wghLyTn5tw5Rqa74qoSUHgg4b7VuZrCSO2VVnLq5f1-Ls88MKr9LHgbgKNFO9LLaLFCfUxYpjqpWAgofWq2CrSu5_8U2J7GjdPjsYv0NVaxp4XD938czsESXZa-8__sHdBFuHfVnpdi3JrZ_G2NrczNyNdcvtN_Wt8Jvy0C6EgsaFv8Sl_nRBMgEOxHVJWC8bUJmpnbv1FyfNcol0Gdhq49E3CgN0o86dasLvpACDxY2y7qRZW_bpGpIq8D2Q9ItCu1yl5k84I2MbzxCfOUUgqK0mCuAtZC6FSeaM6AeLXdpaxUqK4ePgA5thRnjvbZahEFwIDAQABo4ICdDCCAnAwgY8GA1UdIwSBhzCBhIAU79xE0saNwA6jOMB8k8bDQb9Kj_ChaKRmMGQxCzAJBgNVBAYTAktSMQ0wCwYDVQQKDARLSVNBMS4wLAYDVQQLDCVLb3JlYSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eSBDZW50cmFsMRYwFAYDVQQDDA1LSVNBIFJvb3RDQSA0ggIQHDAdBgNVHQ4EFgQU-J-RYCg4i47Qf9T4QjGDHn4eHcAwDgYDVR0PAQH_BAQDAgbAMIGRBgNVHSABAf8EgYYwgYMwgYAGCiqDGoyaRQEBAQowcjBCBggrBgEFBQcCAjA2HjTHdAAgx3jJncEcspQAIK4IxzWssMgcxtDF0MEcACC8HK4J1VwAIMd4yZ3BHAAgx4WyyLLkMCwGCCsGAQUFBwIBFiBodHRwOi8vd3d3Lnllc3NpZ24ub3Iua3IvY3BzLmh0bTBoBgNVHREEYTBfoF0GCSqDGoyaRAoBAaBQME4MCeq5gOyDgeq3oDBBMD8GCiqDGoyaRAoBAQEwMTALBglghkgBZQMEAgGgIgQgY3UxWFnvagNuFVnvQp_oebia1VuGlfIKOvCf6l5SKzowdQYDVR0fBG4wbDBqoGigZoZkbGRhcDovL2RzLnllc3NpZ24ub3Iua3I6MTM4OS9vdT1kcDEwMDAwcDcyOSxvdT1BY2NyZWRpdGVkQ0Esbz15ZXNzaWduLGM9a3I_Y2VydGlmaWNhdGVSZXZvY2F0aW9uTGlzdDA4BggrBgEFBQcBAQQsMCowKAYIKwYBBQUHMAGGHGh0dHA6Ly9vY3NwLnllc3NpZ24ub3JnOjQ2MTIwDQYJKoZIhvcNAQELBQADggEBACSXDS7hbApQ_2QoYZp9qUue12JmKBwkHpEYCSME3bW59E-4eeWNGGql_P-_JMk9po1TAPkX_J-EO35lHpa8ox1welOyNWvsjffG8p8e5bOMZ1AKMdqx_9wGahygRUl1r-wg5-zdTqAoz4xP2zcrXT5LiBBdQbfWE3u6Qbw3Qjve24ysq1gdlEAWfv_ztU3NYE09bPo32EoDKaFV1kSMxrtbWKq7nn5MX_MoGMyxplxM8ECbL_zt7yNPZfsqyMQyCLeLEgmX-ueaQOOmHTtXMg2fq4f5pJTnbgatDgOwb0Rl-rrkjri4mH06T8jdJ4pzlgFfX4El0uIdlZeiEgqIY_cxggIjMIICHwIBATBaMFIxCzAJBgNVBAYTAmtyMRAwDgYDVQQKDAd5ZXNzaWduMRUwEwYDVQQLDAxBY2NyZWRpdGVkQ0ExGjAYBgNVBAMMEXllc3NpZ25DQSBDbGFzcyAyAgQpIEs5MA0GCWCGSAFlAwQCAQUAoGkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjIwMTEwMDg1MDE0WjAvBgkqhkiG9w0BCQQxIgQgE4AQwKR_xmfKaPALeOqWyD11klrc8GdF7khpAqfcvVYwDQYJKoZIhvcNAQEBBQAEggEAZLvHalPdWj6rdf-WUKqVR24wQlSK97oFXNukUb9RebYZnTKWUggoIA1ybxuRpCo2gA_1SjZ26RBluuN7bEPqna2M3uzvEz9amb2ZToJ_X8AwxstAl9aN0KaBF4SCm5oE6Uw9WQdpctNIp-4QWZydVTHkVxepptLpBSsrH8aFP0HNV-OrQCj5-k6uxxj3rMXyGleQZnDm8vaYF81GeSdXJdhR6ao809XO6QbveZMNkB6s7jU9xkdpznGcw2EOw-GFGXTc_luvN9Q7Drf6aQDdeTl20ZsJdtns6Y5fCbwdaIpskVMBhCQvHvfgGA3mWf_sHSgB_5ftKSm_rycyf9Ie5KExMC8GCSqDGoyaRQEKATEiBCAwHhMFZHVtbXkDFQBVf-fJQ3rlVuCtKPsrKnpEKS5mOQ";

        var pkcs7_kakao_login = "MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwGggCSABBgNGWflU+RLnwAAAXZg9C4AhXiXXThwoScAAAAAAACggDCCAiwwggHSoAMCAQICEQCi3LMdbzdJybO3Xllhqms3MAoGCCqGSM49BAMCMG0xCzAJBgNVBAYTAktSMRQwEgYDVQQKDAtLYWthbyBDb3JwLjErMCkGA1UECwwiMUhxamJLeFNEb2dTR0FlV2ZBSnNoMW03b0F1OEhZaG1ZZzEbMBkGA1UEAwwSS2FrYW8gQ2VydCBDQSAtIEMxMB4XDTIwMTEyMjE1MDAwMFoXDTIyMTEyMzE0NTk1OVowZjESMBAGA1UEAwwJ6rmA7IOB6regMVAwTgYKCZImiZPyLGQBAQxANTJkNzdlOGZiOWZkODBlNWM5MDdlZDNiMzE4YjBkNmQyZmNmYTQzNzdlM2E0Y2JmYjQyN2IzMTg0N2VjZjY1OTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABAeYfAPIYzu3PxnnI5wWB7MYlk+yFblh5h8h/funTj40B16d6sr3RjJzp0p7EI4mNj6AuEniZ1HRYBA28tnA4tCjWjBYMAkGA1UdEwQCMAAwDgYDVR0PAQH/BAQDAgeAMDsGCCsGAQUFBwEBBC8wLTArBggrBgEFBQcwAYYfaHR0cHM6Ly9jZXJ0Lmtha2FvLmNvbS9wa2kvb2NzcDAKBggqhkjOPQQDAgNIADBFAiEAm8DmYuR+3pGeHdkwArXc51KO6Sh93gSdHTqZrq1B90YCIEM2z0TAx41CHJdYLH4bctNT4pChNrLgDvuPuPnjZ0bxAAAxge8wgewCAQEwgYIwbTELMAkGA1UEBhMCS1IxFDASBgNVBAoMC0tha2FvIENvcnAuMSswKQYDVQQLDCIxSHFqYkt4U0RvZ1NHQWVXZkFKc2gxbTdvQXU4SFlobVlnMRswGQYDVQQDDBJLYWthbyBDZXJ0IENBIC0gQzECEQCi3LMdbzdJybO3Xllhqms3MA0GCWCGSAFlAwQCAQUAMAoGCCqGSM49BAMCBEcwRQIgKoyahoRZ8k2xaloYTZY+YEaAnlNNBrSu0WEIezv3eFACIQCdPhfWCESy7UVO5LU5Af9Je7X76DL6j4cjMg1L+C0lvwAAAAAAAA==";
        var pkcs7_kakaotalk_login = "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";
        var pkcs7_toss_login  = "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";
        var pkcs7_naver_login = "MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwGggCSABGx7InRleHQiOiJsb2dpbj1yZWdpc3RlckNlcnQmX19DRVJUX1NUT1JFX01FRElBX1RZUEU9TkFWRVImX19ERUxGSU5PX05PTkNFPTVaT2tVVnhDJTJCUXZUTDJDTUU5N0p3dlZKczk0JTNEIn0AAAAAAACggDCCAogwggIuoAMCAQICEQGYQ1KuKclIOrK1kydj3lhyMAoGCCqGSM49BAMCMDcxEjAQBgNVBAMMCU5hdmVyU2lnbjEUMBIGA1UECgwLTkFWRVIgQ29ycC4xCzAJBgNVBAYTAktSMB4XDTIwMTExMjA0MjYyOFoXDTIzMTExMjA0MjYyOFowcjELMAkGA1UEBhMCS1IxDjAMBgNVBAoMBU5hdmVyMRYwFAYDVQQLDA1OYXZlciBBY2NvdW50MRIwEAYDVQQDDAnquYDsg4Hqt6AxJzAlBgoJkiaJk/IsZAEBDBdQcGdaOGl1R29mS1NuOF94SGVnNG53CjBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABLrzp89ub1WLK50sPeUnoBEXJazqhQ5Hk9aw1If++JWLpgDg6b6YkGPMMZa328FrPtasvwfhAEyqIgCQU1y3gqyjgd8wgdwwCQYDVR0TBAIwADBfBgNVHSMEWDBWgBSC9OQZNid3/02pqBhv+3rhTQyshKE7pDkwNzESMBAGA1UEAwwJTmF2ZXJTaWduMRQwEgYDVQQKDAtOQVZFUiBDb3JwLjELMAkGA1UEBhMCS1KCAQowHQYDVR0OBBYEFPoi8wV0VnOGp6kQ49HWv7TzSLgfMA4GA1UdDwEB/wQEAwIGwDA/BggrBgEFBQcBAQQzMDEwLwYIKwYBBQUHMAGGI2h0dHBzOi8vbnNpZ24tZ3cubmF2ZXIuY29tL3BraS9vY3NwMAoGCCqGSM49BAMCA0gAMEUCIQDQxe0ETI+mHrK5c+k181fMWaju2ARHkLrHC+rwdyvFzQIgAnG9OaxwcjEpltZoeEqzXWQhpEPTMZivUs2qNtN6CQswggFcMIIBAaADAgECAgEKMAoGCCqGSM49BAMCMDcxEjAQBgNVBAMMCU5hdmVyU2lnbjEUMBIGA1UECgwLTkFWRVIgQ29ycC4xCzAJBgNVBAYTAktSMB4XDTE5MTIzMTE1MDAwMFoXDTM5MTIzMTE1MDAwMFowNzESMBAGA1UEAwwJTmF2ZXJTaWduMRQwEgYDVQQKDAtOQVZFUiBDb3JwLjELMAkGA1UEBhMCS1IwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAASm1Qc7kyJtsZ3FHFO0QGc39E966rbTKCb7mfHz+2ESG085tOBTFM3oWZcoJ1ZbwIEmuO05y+OleXLV6Q+LSLV6MAoGCCqGSM49BAMCA0kAMEYCIQDiW2MxydBQ5mNJWm+yKqa+8DqOZcK0lHDYolRhG2am9gIhAPBBAfcEr3b838QOUKqfe8kXs16TQOoZEqV4B1A2NxYIAAAxgbkwgbYCAQEwTDA3MRIwEAYDVQQDDAlOYXZlclNpZ24xFDASBgNVBAoMC05BVkVSIENvcnAuMQswCQYDVQQGEwJLUgIRAZhDUq4pyUg6srWTJ2PeWHIwDQYJYIZIAWUDBAIBBQAwCgYIKoZIzj0EAwIESDBGAiEAzxJ51t4bmqc5Idpi1hYz34bmqtKErTiG+60R5vthsRMCIQCsKhxXUw/o3htCpTlIUfiQIB/jaHYZbFRtsAFX6dclBwAAAAAAAA==";
        var pkcs7_naver2_login= "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";
        var pkcs7_pass_login  = "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";
        var pkcs7_payco_login = "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";

        var pkcs7_kakao_sign  = "MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwGggCSABIHVYWNjb3VudD01MjQ5MDItMDEtMDU1OTgzJmFtb3VudD0xMDAwMCZyZWN2QmFuaz3tmY3svansnYDtlokmcmVjdkFjY291bnQ9MDk3LTIxLTA0NDEtMTIwJuuwm+uKlOu2hD3quYDrqqjqtbAmX19ERUxGSU5PX05PTkNFPTMyczcydHdqSlJUM3ZpUktZQjl1d3B3bTRQdyUzRAoKPCEtLSB8YTBjNGJmMGNhMTA3NDUyNzg4YzAwYjE5MmI0MDVlYWN8MTYwNzk0NTIwMTAwMHwgLS0+AAAAAAAAoIAwggIsMIIB0qADAgECAhEAotyzHW83Scmzt15ZYaprNzAKBggqhkjOPQQDAjBtMQswCQYDVQQGEwJLUjEUMBIGA1UECgwLS2FrYW8gQ29ycC4xKzApBgNVBAsMIjFIcWpiS3hTRG9nU0dBZVdmQUpzaDFtN29BdThIWWhtWWcxGzAZBgNVBAMMEktha2FvIENlcnQgQ0EgLSBDMTAeFw0yMDExMjIxNTAwMDBaFw0yMjExMjMxNDU5NTlaMGYxEjAQBgNVBAMMCeq5gOyDgeq3oDFQME4GCgmSJomT8ixkAQEMQDUyZDc3ZThmYjlmZDgwZTVjOTA3ZWQzYjMxOGIwZDZkMmZjZmE0Mzc3ZTNhNGNiZmI0MjdiMzE4NDdlY2Y2NTkwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQHmHwDyGM7tz8Z5yOcFgezGJZPshW5YeYfIf37p04+NAdenerK90Yyc6dKexCOJjY+gLhJ4mdR0WAQNvLZwOLQo1owWDAJBgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIHgDA7BggrBgEFBQcBAQQvMC0wKwYIKwYBBQUHMAGGH2h0dHBzOi8vY2VydC5rYWthby5jb20vcGtpL29jc3AwCgYIKoZIzj0EAwIDSAAwRQIhAJvA5mLkft6Rnh3ZMAK13OdSjukofd4EnR06ma6tQfdGAiBDNs9EwMeNQhyXWCx+G3LTU+KQoTay4A77j7j542dG8QAAMYHvMIHsAgEBMIGCMG0xCzAJBgNVBAYTAktSMRQwEgYDVQQKDAtLYWthbyBDb3JwLjErMCkGA1UECwwiMUhxamJLeFNEb2dTR0FlV2ZBSnNoMW03b0F1OEhZaG1ZZzEbMBkGA1UEAwwSS2FrYW8gQ2VydCBDQSAtIEMxAhEAotyzHW83Scmzt15ZYaprNzANBglghkgBZQMEAgEFADAKBggqhkjOPQQDAgRHMEUCIQCyLaRHRUJInh0WmLqbq3zgowzkZPoV3+14w1wC/n/UhQIgXk/1npDe10NHiOav1dit6Y6S4171aYhg/B9pY8jzyw0AAAAAAAA=";
        var pkcs7_kakaotalk_sign = "MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwGggCSABIG8eyJkYXRhIjoi7JWI64WV7ZWY7IS47JqUISIsInR4SWQiOiIwMWIwODMxNDFhLTRlZWQtNDQ0Yi05YmY5LTBjYWYxMTgxN2MwYiIsImRlc2MiOiJbe1wi7JqU7LKt6rWs67aEXCI6XCLsoITsnpDshJzrqoVcIn0se1wi7JqU7LKt6riw6rSAXCI6XCLsnITspojrsqDrnbxcIn0se1wi67Cb64qU7J20XCI6XCLsnbTspIDtmJVcIn1dIn0AAAAAAACggDCCA9EwggN3oAMCAQICFQDywlny4T8Hkqze12ZeIG9jXuOATTAKBggqhkjOPQQDAjBgMQswCQYDVQQGEwJLUjEOMAwGA1UEChMFS0FLQU8xLjAsBgNVBAsTJUtha2FvIENlcnRpZmljYXRpb24gQXV0aG9yaXR5IENlbnRyYWwxETAPBgNVBAMTCEtBS0FPLUNBMB4XDTIyMDEyMjA3MjUyM1oXDTI1MDEyMjA3MjUyMlowaTELMAkGA1UEBhMCS1IxDjAMBgNVBAoMBUtBS0FPMS4wLAYDVQQLDCVLYWthbyBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eSBDZW50cmFsMRowGAYDVQQDDBHsnbTspIDtmJUxMDAwMDQwMDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABAA8tnCusjKqUrCqe1MvCMdE97IMStd14uoKN5n4kk/I5osmdScO7qY+MEfVn+DfteznXSCQQ1BPhU/jE+ztvgqjggIDMIIB/zAJBgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIGwDBWBgNVHSAETzBNMAwGCiqDGoybIwEBAQIwPQYIKwYBBQUHAgEwMTAvBggrBgEFBQcCARYjaHR0cHM6Ly93YWxsZXQua2FrYW8uY29tL3BvbGljeS9jcHMwgYwGA1UdHwSBhDCBgTB/oH2ge4Z5bGRhcDovL2xkYXAta3BraS5rYWthby5jb206Mzg5L0NOPUNQTjc4MjEsT1U9S2FrYW8tQ2VydGlmaWNhdGlvbi1BdXRob3JpdHktQ2VudHJhbCxPPUtBS0FPLEM9S1I/Y2VydGlmaWNhdGVSZXZvY2F0aW9uTGlzdDAdBgNVHQ4EFgQUGGHXCIjmY4kXGqajishR/fiI/WUwgdsGA1UdIwSB0zCB0IBbMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAELg0g/qGPpi+UB0JB1JcYGSXuLEI0nDfaw/Z2r0+b94Y9JY+LuAa55fx4MtXS9uwAjeYwK5q2URnzg+znZgAFFKFppGcwZTELMAkGA1UEBhMCS1IxDjAMBgNVBAoTBUtBS0FPMS4wLAYDVQQLEyVLYWthbyBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eSBDZW50cmFsMRYwFAYDVQQDEw1LQUtBTy1ST09ULUNBggYBeuGCZ8YwCgYIKoZIzj0EAwIDSAAwRQIgC5Rp1VQiw/iBjctfY+mrGDY7c+v89++aI2+AYbqPSnQCIQCljTZnOgFxLlQkqmpl5Dv7x4JxInjriBqDWpqK2RhJpAAAMYHlMIHiAgEBMHkwYDELMAkGA1UEBhMCS1IxDjAMBgNVBAoTBUtBS0FPMS4wLAYDVQQLEyVLYWthbyBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eSBDZW50cmFsMREwDwYDVQQDEwhLQUtBTy1DQQIVAPLCWfLhPweSrN7XZl4gb2Ne44BNMA0GCWCGSAFlAwQCAQUAMAoGCCqGSM49BAMCBEcwRQIhAL0IEGukFR+QnCcFyUhTqOSLacD5b/5eNS0+/9ekyozmAiAljite90Tza4EqQ26japjJ/gyBK2hosM/hyOwdMGceygAAAAAAAA==";
        var pkcs7_toss_sign   = "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";
        var pkcs7_naver_sign  = "MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwGggCSABIG0eyJkYXRhIjpbeyLrgrTsmqkiOiJhY2NvdW50PTUyNDkwMi0wMS0wNTU5ODMmYW1vdW50PTEwMDAwJnJlY3ZCYW5rPe2Zjey9qeydgO2WiSZyZWN2QWNjb3VudD0wOTctMjEtMDQ0MS0xMjAm67Cb64qU67aEPeq5gOuqqOq1sCZfX0RFTEZJTk9fTk9OQ0U9azZ5bFdmQjVyMDk2UlZVayUyQnRVYXM5Um9wV0ElM0QifV19AAAAAAAAoIAwggKIMIICLqADAgECAhEBmENSrinJSDqytZMnY95YcjAKBggqhkjOPQQDAjA3MRIwEAYDVQQDDAlOYXZlclNpZ24xFDASBgNVBAoMC05BVkVSIENvcnAuMQswCQYDVQQGEwJLUjAeFw0yMDExMTIwNDI2MjhaFw0yMzExMTIwNDI2MjhaMHIxCzAJBgNVBAYTAktSMQ4wDAYDVQQKDAVOYXZlcjEWMBQGA1UECwwNTmF2ZXIgQWNjb3VudDESMBAGA1UEAwwJ6rmA7IOB6regMScwJQYKCZImiZPyLGQBAQwXUHBnWjhpdUdvZktTbjhfeEhlZzRudwowWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAS686fPbm9ViyudLD3lJ6ARFyWs6oUOR5PWsNSH/viVi6YA4Om+mJBjzDGWt9vBaz7WrL8H4QBMqiIAkFNct4Kso4HfMIHcMAkGA1UdEwQCMAAwXwYDVR0jBFgwVoAUgvTkGTYnd/9NqagYb/t64U0MrIShO6Q5MDcxEjAQBgNVBAMMCU5hdmVyU2lnbjEUMBIGA1UECgwLTkFWRVIgQ29ycC4xCzAJBgNVBAYTAktSggEKMB0GA1UdDgQWBBT6IvMFdFZzhqepEOPR1r+080i4HzAOBgNVHQ8BAf8EBAMCBsAwPwYIKwYBBQUHAQEEMzAxMC8GCCsGAQUFBzABhiNodHRwczovL25zaWduLWd3Lm5hdmVyLmNvbS9wa2kvb2NzcDAKBggqhkjOPQQDAgNIADBFAiEA0MXtBEyPph6yuXPpNfNXzFmo7tgER5C6xwvq8Hcrxc0CIAJxvTmscHIxKZbWaHhKs11kIaRD0zGYr1LNqjbTegkLMIIBXDCCAQGgAwIBAgIBCjAKBggqhkjOPQQDAjA3MRIwEAYDVQQDDAlOYXZlclNpZ24xFDASBgNVBAoMC05BVkVSIENvcnAuMQswCQYDVQQGEwJLUjAeFw0xOTEyMzExNTAwMDBaFw0zOTEyMzExNTAwMDBaMDcxEjAQBgNVBAMMCU5hdmVyU2lnbjEUMBIGA1UECgwLTkFWRVIgQ29ycC4xCzAJBgNVBAYTAktSMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEptUHO5MibbGdxRxTtEBnN/RPeuq20ygm+5nx8/thEhtPObTgUxTN6FmXKCdWW8CBJrjtOcvjpXly1ekPi0i1ejAKBggqhkjOPQQDAgNJADBGAiEA4ltjMcnQUOZjSVpvsiqmvvA6jmXCtJRw2KJUYRtmpvYCIQDwQQH3BK92/N/EDlCqn3vJF7Nek0DqGRKleAdQNjcWCAAAMYG4MIG1AgEBMEwwNzESMBAGA1UEAwwJTmF2ZXJTaWduMRQwEgYDVQQKDAtOQVZFUiBDb3JwLjELMAkGA1UEBhMCS1ICEQGYQ1KuKclIOrK1kydj3lhyMA0GCWCGSAFlAwQCAQUAMAoGCCqGSM49BAMCBEcwRQIhAPy1udikU+5n1jamQ/A3ZtuTZYFWn4pap8KwFgG8QjdmAiA5RvT2NTbYymS+1PoUtVqFKG6iItcDjzxsjwxB6SYHawAAAAAAAA==";
        var pkcs7_naver2_sign = "MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwGggCSABHt7ImRhdGEiOlt7IuuCtOyaqSI6IuyViOuFle2VmOyEuOyalCEifV0sIm5vbmNlIjoidDZ2azI3M2JwMjN4RjFKT3lFSUswV2dzbC1TZFBjNkZobzZ5ZFZmVk1BYVpIQSIsInRpbWVzdGFtcCI6MTY0MzkzODk1NDc4OX0AAAAAAACggDCCAwEwggKooAMCAQICEQFJSITwEdNFeaf07gIc5ln8MAoGCCqGSM49BAMCME0xCzAJBgNVBAYTAktSMRQwEgYDVQQKEwtOQVZFUiBDb3JwLjETMBEGA1UECxMKTkFWRVIgU2lnbjETMBEGA1UEAxMKTkFWRVIgQ0EgMTAeFw0yMjAxMTgwMjMyMjVaFw0yNTAxMTcxNTAwMDBaMGoxCzAJBgNVBAYTAktSMQ4wDAYDVQQKDAVOYXZlcjEWMBQGA1UECwwNTmF2ZXIgQWNjb3VudDESMBAGA1UEAwwJ7J207KSA7ZiVMR8wHQYDVQQFExY5aGJRbmR3QVlxdmhSLUNfMFVuZVJBMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEUazYaIY/yq0K/8jxcG13kNbqK2tYR85537GwPVD2cLvZ4ElXxi1DS3YTojSHwWOtRpDnNaFvKm55om7jjS03r6OCAUowggFGMB0GA1UdDgQWBBQP1BKP0vs8Qe/wBU2gYS/pk8R1iDB8BgNVHSMEdTBzgBSZYq6yVWzf8RUc4v95PGeF1ZErFqFVpFMwUTELMAkGA1UEBhMCS1IxFDASBgNVBAoTC05BVkVSIENvcnAuMRMwEQYDVQQLEwpOQVZFUiBTaWduMRcwFQYDVQQDEw5OQVZFUiBSb290Q0EgMYIEMhYFLTAMBgNVHRMBAf8EAjAAMDsGCCsGAQUFBwEBBC8wLTArBggrBgEFBQcwAYYfaHR0cDovL29jc3AuZWt5Yy5uYXZlci5jb20vb2NzcDBMBgNVHSABAf8EQjBAMD4GCiqDGoybIQEBAgEwMDAuBggrBgEFBQcCARYiaHR0cHM6Ly9la3ljLm5hdmVyLmNvbS9wa2kvY3BzL2NwczAOBgNVHQ8BAf8EBAMCBsAwCgYIKoZIzj0EAwIDRwAwRAIgZLKrXhgpt3/WRpgA4vUUJ4Pcrkwr8KBs4VMJWM8EIuICIBiIT5L6Vby+YDY/jn4HoxjwW/DteuNsR9W2Mf1gQyBMMIICqzCCAjCgAwIBAgIEMhYFLTAMBggqhkjOPQQDAwUAMFExCzAJBgNVBAYTAktSMRQwEgYDVQQKEwtOQVZFUiBDb3JwLjETMBEGA1UECxMKTkFWRVIgU2lnbjEXMBUGA1UEAxMOTkFWRVIgUm9vdENBIDEwHhcNMjEwNjE3MDgwMTM4WhcNMzEwNjE1MDgwMTM4WjBNMQswCQYDVQQGEwJLUjEUMBIGA1UEChMLTkFWRVIgQ29ycC4xEzARBgNVBAsTCk5BVkVSIFNpZ24xEzARBgNVBAMTCk5BVkVSIENBIDEwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAS0OoLZncFbhLfjCnqLPSgSpmarAY0WM9xTScGlgxtj3jBCyXl2h08AHjfAqxNTAwjThZQIF4l41N2QPuo+J5nBo4H3MIH0MEYGA1UdIAEB/wQ8MDowOAYEVR0gADAwMC4GCCsGAQUFBwIBFiJodHRwczovL2VreWMubmF2ZXIuY29tL3BraS9jcHMvY3BzMA8GA1UdJAEB/wQFMAOAAQAwHwYDVR0jBBgwFoAUroSuPBBRud2Os7gtD1luoNZ2A6AwEgYDVR0TAQH/BAgwBgEB/wIBADA1BgNVHR8ELjAsMCqgKKAmhiRodHRwOi8vZWt5Yy5uYXZlci5jb20vcGtpL3JjYS9jYS5jcmwwDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBSZYq6yVWzf8RUc4v95PGeF1ZErFjAMBggqhkjOPQQDAwUAA2cAMGQCMB/ltmqNQW7INMW7T3UjbZ3N61g0MGEUFCstmPu1FmA6q//4qNoZozu2Wic9QcvH4gIwPaAi6qzQZ73gDL6QT3Qe99ho2bN94QxpNWoagmhfiwb3gAxbC4cImnt9fTyYtDnwMIICFjCCAZugAwIBAgIEXlMjWDAMBggqhkjOPQQDAwUAMFExCzAJBgNVBAYTAktSMRQwEgYDVQQKEwtOQVZFUiBDb3JwLjETMBEGA1UECxMKTkFWRVIgU2lnbjEXMBUGA1UEAxMOTkFWRVIgUm9vdENBIDEwHhcNMjEwNjA0MDc1MjU1WhcNNDEwNTMwMDc1MjU1WjBRMQswCQYDVQQGEwJLUjEUMBIGA1UEChMLTkFWRVIgQ29ycC4xEzARBgNVBAsTCk5BVkVSIFNpZ24xFzAVBgNVBAMTDk5BVkVSIFJvb3RDQSAxMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEoX+2TwHhPLAVeFsOirPR6RLVtWe8k+DImuEdRGjX7cxq9+oJwyZuvTfB8EH+kzyegYe2VdORkerbZKEi/tLmQ31afO46YO2ZCsEySvWdWVWdhhtZ1uRZrwQqmw01ByQ/o0IwQDAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBBjAdBgNVHQ4EFgQUroSuPBBRud2Os7gtD1luoNZ2A6AwDAYIKoZIzj0EAwMFAANnADBkAjBZhqfnbMUQKmt1t1xxFqEMAHIbN2S8IqEKliIKDgsGpvQAuP2DyKDRPiKlzeE5hf0CMF74vL9fanFZ/0LADFmZsRjZV8WIxKEAKoHlNFoyFlIeGeJ6hWm9Unag6SA6X663ngAAMYHNMIHKAgEBMGIwTTELMAkGA1UEBhMCS1IxFDASBgNVBAoTC05BVkVSIENvcnAuMRMwEQYDVQQLEwpOQVZFUiBTaWduMRMwEQYDVQQDEwpOQVZFUiBDQSAxAhEBSUiE8BHTRXmn9O4CHOZZ/DANBglghkgBZQMEAgEFADAKBggqhkjOPQQDAgRGMEQCIG983M+qOzLoFsxGccjTQO06XxXgnHWusJ4XvJwsOl4TAiBHtY89URZI3/g/eFi+HVLjXcPuV1Lr0Dh49o4IeUuvHQAAAAAAAA==";
        var pkcs7_pass_sign   = "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";
        var pkcs7_payco_sign  = "MIIOXAYJKoZIhvcNAQcCoIIOTTCCDkkCAQExDzANBglghkgBZQMEAgEFADB6BgkqhkiG9w0BBwGgbQRrYWNjb3VudD01MjQ5MDItMDEtMDU1OTgzJmFtb3VudD0xMDAwMCZyZWN2QmFuaz3tmY3svansnYDtlokmcmVjdkFjY291bnQ9MDk3LTIxLTA0NDEtMTIwJuuwm+uKlOu2hD3quYDrqqjqtbCgggtTMIIFrTCCA5WgAwIBAgICA+kwDQYJKoZIhvcNAQELBQAwXjELMAkGA1UEBhMCS1IxFzAVBgNVBAoMDk5ITiBQQVlDTyBDT1JQMRIwEAYDVQQLDAlQQVlDTyBQS0kxIjAgBgNVBAMMGU5ITiBQQVlDTyBST09UIENBIENsYXNzIDEwHhcNMjAwMTAxMDAwMDAwWhcNMzAxMjMxMjM1OTU5WjBZMQswCQYDVQQGEwJLUjEXMBUGA1UECgwOTkhOIFBBWUNPIENPUlAxEjAQBgNVBAsMCVBBWUNPIFBLSTEdMBsGA1UEAwwUTkhOIFBBWUNPIENBIENsYXNzIDEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDD3aBLF+0BiW9haoRgCsJIsFb9btPwvMTzwzKeL9FP73v4VePUZjOZH/XyeZzVVxxVoRdJ7taj6DMaRO3LnQ69RvRtfHnYMBYOD6CWu4KULRjlY3UtGLKYuxhK3bb22e5F8Rc/HwEW/mSImrRdi9qQmxr8+FT7Bv+B4OSyYaEYkZTTNGy8TMWcAZVhQag+OuHzKkWZl/UUnu3n/5J2v6tWnBVc6QVowTdBzlmNM2UuDc4ngzRLQTtLhaYWPcVlV22MlYAS/70lZryj4FHXkbjFt9qW9xKCyvBQ3Nk0MxbrRZrN6Cfd3LpjiS0QJkq7AosNlqTGC4eLYkf94yeNJ8dZAgMBAAGjggF4MIIBdDCBhgYDVR0jBH8wfYAUehrdFe8PLDoE5EYAWu1g4HSAlcShYqRgMF4xCzAJBgNVBAYTAktSMRcwFQYDVQQKDA5OSE4gUEFZQ08gQ09SUDESMBAGA1UECwwJUEFZQ08gUEtJMSIwIAYDVQQDDBlOSE4gUEFZQ08gUk9PVCBDQSBDbGFzcyAxggEBMB0GA1UdDgQWBBTO9737gwxdIj3d6Va9gsxWkl1PxTAOBgNVHQ8BAf8EBAMCAcYwgZcGA1UdIAEB/wSBjDCBiTCBhgYEVR0gADB+MDMGCCsGAQUFBwIBFidodHRwczovL2lkLnBheWNvLmNvbS9jZXJ0aWZpY2F0ZUNwcy5uaG4wRwYIKwYBBQUHAgIwOww57J20IOyduOymneyEnOuKlCDtjpjsnbTsvZQg7KSR6rOEIENBIOyduOymneyEnCDsnoXri4jri6QuMBIGA1UdEwEB/wQIMAYBAf8CAQAwDAYDVR0kBAUwA4ABADANBgkqhkiG9w0BAQsFAAOCAgEAn+ONluv7kU1k7l4Y+fZ3VVtkCtS6QXcmNupSXz1kFyrs/x7y5KPgfCeTAooYPxpA20SRCa10Y0Nj2hC6pjg6ntSvum2MuBB/yijgqLaZ5kJHNrArrVsbwimzNjJaLnj+r6yIJ/HCznKMJqWy9sUY1zOJph5cns4YFGWwpKhZ1YR9lbgtzaphvGjYEBTeybF3PUFCZnZO6933A+Q2RIZYNmMdme/ufsvJVbGbr3X1RQ4hnWjtpw4xaP04EPqybNj3g7svhbDKkyzuv34yqs8tPfPviOZ75GCpQvfMdVVlWs4K0298itS29AgPrxwy3Tia9sag406MRoHPvOHf1M/gJCv6fwmHvlvvwuVKe1A+7gq3oYd7S1sBRYg/QEv5gd4Mn+6tiVcU/uVF7yLT4sL/TCtsr6XIFlEez3mtCCT8V1TVJATjgeyG+ZBZOog7SFaKQDS8u4QK0kAdn3CdZ+xnbrngm1lkeBugPatwQIxvY/UQWBP1zw36qSY0FUipQH7NAvsKkz3Q6xiax/g5BGHugp2mMxzBPhKfQY2NArScN0l0g87qyZ2iAcduoEfNrIoB2wrl0gd8YOn3JVMJaVZR/r0imMK04lAlg3WVHAmRFn/xcxKkxeK2cEtsvJ8cfWgiSuS+ibtbU4TCO2rjHALkMII/n7HwEUbh4K29PAOpf7swggWeMIIEhqADAgECAgMDUwswDQYJKoZIhvcNAQELBQAwWTELMAkGA1UEBhMCS1IxFzAVBgNVBAoMDk5ITiBQQVlDTyBDT1JQMRIwEAYDVQQLDAlQQVlDTyBQS0kxHTAbBgNVBAMMFE5ITiBQQVlDTyBDQSBDbGFzcyAxMB4XDTIxMDQxMzAwMDAwMFoXDTIzMDQxMjIzNTk1OVowTTELMAkGA1UEBhMCS1IxFzAVBgNVBAoTDk5ITiBQQVlDTyBDT1JQMREwDwYDVQQLEwhwZXJzb25hbDESMBAGA1UEAwwJ6rmA7IOB6regMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzkaxel1qVwZ8A4N+AO8/+vivwW6rGaMCRnUmcdgxPJdu6PrTiSSN+NjEAGFtMpg8lvrFcDlo6xNSVZFoMqpB/sGU1jQGrtlTFbOVc90IM3Ooh6KMwCmo6ZCRLMSBDAm4rJZZ97vhJ8lvRD0kNx/o+H9Jlk9zNnSr6CPHQm12o/YZ5AqGJob8ZJt1eLu3fnvmAwYCGK2jvVEa1oySAkuwaF7kawINvaADuUBVBxlYxeDLY9sbLE5g3sjBXNciaj1/WWt4NgxfsyrWParV+Nowb1ncFRXfuFyoofJrFQodYUAsvVyQt9lMO/1IvinhQyG2qa0w2+vjH/k2y1LnhAE+VQIDAQABo4ICeTCCAnUwgYgGA1UdIwSBgDB+gBTO9737gwxdIj3d6Va9gsxWkl1PxaFipGAwXjELMAkGA1UEBhMCS1IxFzAVBgNVBAoMDk5ITiBQQVlDTyBDT1JQMRIwEAYDVQQLDAlQQVlDTyBQS0kxIjAgBgNVBAMMGU5ITiBQQVlDTyBST09UIENBIENsYXNzIDGCAgPpMB0GA1UdDgQWBBQE4lAD753Atk2qyRfY3b3ULvNnXjAOBgNVHQ8BAf8EBAMCBsAwgaUGA1UdIAEB/wSBmjCBlzCBlAYJKoMajJsaAQEBMIGGMDMGCCsGAQUFBwIBFidodHRwczovL2lkLnBheWNvLmNvbS9jZXJ0aWZpY2F0ZUNwcy5uaG4wTwYIKwYBBQUHAgIwQwxB7J20IOyduOymneyEnOuKlCDtjpjsnbTsvZQg6rCA7J6F7J6QKOqwnOyduCkg7J247Kad7IScIOyeheuLiOuLpC4waAYDVR0RBGEwX6BdBgkqgxqMmkQKAQGgUDBODAnquYDsg4Hqt6AwQTA/BgoqgxqMmkQKAQEBMDEwCwYJYIZIAWUDBAIBoCIEIH3a0Q3TXGtuyDRw2MH4feGW4XRJ+kxl42+ik+sueo/rMFUGA1UdHwROMEwwSqBIoEaGRGh0dHBzOi8vY3JsLnBheWNvLmNvbS9wYXljb0NBL05ITlBheWNvQ2VydGlmaWNhdGVSZXZvY2F0aW9uTGlzdDEuY3JsMDIGCCsGAQUFBwEBBCYwJDAiBggrBgEFBQcwAYYWaHR0cHM6Ly9vY3NwLnBheWNvLmNvbTAcBgkqhkiG9w0BCQUEDxcNMjEwNDEzMDMzMDI3WjANBgkqhkiG9w0BAQsFAAOCAQEAeuNajzRwy2WIo6eO1J8P+n5yasA8Zg2FH0BdWhuuB86DDPz355se5p2gJQl6D+3pJZLOV4GNgnGkYg3yEz3lBFCtFkL7KJQc84SOIVReeqX/VtypQNckWFX1lJo0X18ZI+p2ifmhm+lavlYOJay5IpjMa3tMCa+M69moM4FT/P4uUmDiqJ4uH7pnXR5/A+Y1so8Q/JQSST+RuYSpWxgzNJslG7IyHbFLFPLQARA06JfLIJRQrCXJMTcYVA9qtH9GaIMk31jav1T3hH+mFvtfdxLiOQAT5tPASaWqgSrTj2ZApQ3Iyluf6UX6eyYQ1d0Xtyz4YkYMG7eOFXxaJcoT3jGCAl4wggJaAgEBMGAwWTELMAkGA1UEBhMCS1IxFzAVBgNVBAoMDk5ITiBQQVlDTyBDT1JQMRIwEAYDVQQLDAlQQVlDTyBQS0kxHTAbBgNVBAMMFE5ITiBQQVlDTyBDQSBDbGFzcyAxAgMDUwswDQYJYIZIAWUDBAIBBQCggdAwNgYIKoMajJsaAwExKgQo0hmr1uhuJD2ZntOLyKBykrpO3EkPNj4r9h+IiigzldEJsWIAIDawMTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMTEyMDkwMzM1NDdaMC0GCSqGSIb3DQEJNDEgMB4wDQYJYIZIAWUDBAIBBQChDQYJKoZIhvcNAQELBQAwLwYJKoZIhvcNAQkEMSIEIJFmJ3CCqxsEFKcMu82r+KyMU+Wa6YqH8P51X5D9UJUuMA0GCSqGSIb3DQEBCwUABIIBAK71gyiEjP8LPmg91xfeWome++PawJmSzccvZDk1JmdZwaBkQfOPpbX+L1+hKhPnywm7OLnrva/j/G5LqR6VvwMLQCaYP0DhOjwWjK09vaRa4btWFBBj+SKcqMvd2edRMsCh7oD7N80aLdzhie1b8zni0Y32gmzlpoLGuWfPiY/40zeWuKkYzA8iG6vroEqqu7GgMUpufJnmyxXDV896Tl3CqGmS7Hu434uSI7qxJDmnsOkz+SZqLbDPrqdy9KvlvdrjJ4XL9IyFs0n0BkXoqUx4RMNSoh7NVe3riZW5gvQAlaerCajUKKloATA1cZyhY4jqQTo1ArPCJsUimLg0N/E=";

        var test_pkcs7 = pkcs7_npkiR;
        if (_Delfino_SystemMode == "test") test_pkcs7 = pkcs7_npkiT;

        if (provider != "" && !confirm(provider + " 서명데이타를 테스트 하시겠습니까?")) return;
        if (provider == "NPKI") {
            test_pkcs7 = pkcs7_npkiR;
            if (_Delfino_SystemMode == "test") test_pkcs7 = pkcs7_npkiT;
        } else if (provider == "GPKI") {
            test_pkcs7 = pkcs7_gpkiR;
        } else if (provider == "yessR") {
            test_pkcs7 = pkcs7_yessR;
        } else if (provider == "yessT") {
            test_pkcs7 = pkcs7_yessT;
        } else if (provider == "kakao") {
            test_pkcs7 = pkcs7_kakao_login;
            if ("sign" == authType) test_pkcs7 = pkcs7_kakao_sign;
        } else if (provider == "kakaotalk") {
            test_pkcs7 = pkcs7_kakaotalk_login;
            if ("sign" == authType) test_pkcs7 = pkcs7_kakaotalk_sign;
        } else if (provider == "naver") {
            test_pkcs7 = pkcs7_naver_login;
            if ("sign" == authType) test_pkcs7 = pkcs7_naver_sign;
        } else if (provider == "naver2") {
            test_pkcs7 = pkcs7_naver2_login;
            if ("sign" == authType) test_pkcs7 = pkcs7_naver2_sign;
        } else if (provider == "toss") {
            test_pkcs7 = pkcs7_toss_login;
            if ("sign" == authType) test_pkcs7 = pkcs7_toss_sign;
        } else if (provider == "pass") {
            test_pkcs7 = pkcs7_pass_login;
            if ("sign" == authType) test_pkcs7 = pkcs7_pass_sign;
        } else if (provider == "payco") {
            test_pkcs7 = pkcs7_payco_login;
            if ("sign" == authType) test_pkcs7 = pkcs7_payco_sign;
        }
        if (provider == "NPKI" || provider == "GPKI" || provider == "payco" || provider == "") {
            document.delfinoForm.VID_RANDOM.value = "TEST_vidRandom_TEST";
        } else {
            document.delfinoForm.VID_RANDOM.value = "";
        }

        document.delfinoForm._action.value = "TEST_pkcs7";
        document.delfinoForm.certStatusCheckType.value = document.inputForm.certStatusCheckType.value;
        document.delfinoForm.idn.value = document.inputForm.idn.value;
        if (document.delfinoForm.PKCS7.value == "" || provider != "") document.delfinoForm.PKCS7.value = test_pkcs7;
        //document.delfinoForm.action = "./signResultCertInfo.jsp";
        document.delfinoForm.submit();
    }
    </script>

<% if ("on".equals(request.getParameter("auto"))) { %>
    <script type="text/javascript">
    //<![CDATA[
    window.onload= function() {
        setTimeout("TEST_certLogin()", 200);
    };
    //]]>
    </script>
<% }  %>

  <hr />
  <div style="font-size:9pt;" align="left">
    <%=logDate.format(new java.util.Date())%>
    <script type="text/javascript">try {document.write("["+(DC_platformInfo.Mobile?"mobile,":"")+(DC_platformInfo.x64?DC_platformInfo.name+",":"")+DC_browserInfo.name+","+DC_browserInfo.version+"]");} catch(err) {document.write("<b>"+err+"</b>");}</script>
    Copyright &#169; 2008-2015, <a href='http://help.wizvera.com' target="_new">WIZVERA</a> Co., Ltd. All rights reserved
    <script type="text/javascript">
        try {top.document.title = "[" + Delfino.getModule() + "]" + top.document.title;} catch(err) {}
        var hostname = document.location.hostname;
        if (hostname.indexOf("wizvera.com") > 0) {
            var idx = hostname.indexOf(".");
            var oldHost = hostname.substring(0, idx);
            var newHost = oldHost + "2";
            if (hostname.indexOf("2") > 0 || hostname.indexOf("1") > 0) newHost = hostname.substring(0, idx-1);
            document.write("&nbsp;&nbsp;<a href='" + window.location.href.replace(oldHost, newHost) + "'>" + newHost + "</a>");

            var newProtocol = ("https:" == window.location.protocol) ? "http:" : "https:";
            var newSite = window.location.href.replace(window.location.protocol, newProtocol);
            if ("https:" == newProtocol) {
                newSite = newSite.replace(":8080", ":8443");
            } else {
                newSite = newSite.replace(":8443", ":8080");
            }
            document.write(" <a href='" + newSite + "'>" + newProtocol + "</a>");
            document.write(" <br/>[" + navigator.userAgent + "] [<a href='javascript:alert(document.cookie);'>cookie</a>]");
        }
    </script>
  </div>
</body>
</html>
