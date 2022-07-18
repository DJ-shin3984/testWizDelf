<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.wizvera.vpcg.*"%>
<%@ page import="java.util.Properties"%>
<%@ page import="java.io.*"%>
<%!
    VpcgSignResultService vpcgSignResultService;

    public void jspInit() {
        Properties properties = new Properties();
        ServletConfig servletConfig = getServletConfig();
        ServletContext context = servletConfig.getServletContext();
        FileInputStream fin = null;
        Reader in = null;
        boolean useDelfinoConfig = true;
        try{
            if (useDelfinoConfig) {
                //com.wizvera.WizveraConfig delfinoConfig = new com.wizvera.WizveraConfig(getServletConfig().getServletContext().getRealPath("WEB-INF") + "/lib/delfino.properties");
                com.wizvera.WizveraConfig delfinoConfig = com.wizvera.WizveraConfig.getDefaultConfiguration();
  		        vpcgSignResultService = new VpcgSignResultServiceImpl(delfinoConfig.getVpcgConfig());
            } else {
                String wizveraHome = System.getProperty("wizvera.home");
                if(wizveraHome==null){
                    throw new RuntimeException("missing 'wizvera.home' system property");
                }
                String vpcgConfigFile = wizveraHome + "/vpcg/conf/delfino-vpcg.properties";
                fin = new FileInputStream(vpcgConfigFile);
                in = new InputStreamReader(fin, "UTF-8");

                properties.load(in);
  		        vpcgSignResultService = new VpcgSignResultServiceImpl(new VpcgConfig(properties));
            }
        }catch(Exception e){
            throw new RuntimeException("delfino-vpcg.properties load fail", e);
        }finally{
            try{
                if(fin!=null) fin.close();
            }catch(IOException ignore){}
            try{
                if(in!=null) in.close();
            }catch(IOException ignore){}
        }
    }
    String escapeHtml(String source){
        if(source==null) return null;
        return source.replace("<", "&lt;").replace("&", "&amp;");
    }
%>
<%

    if(request.getCharacterEncoding()==null){
        request.setCharacterEncoding("utf-8");
    }
    if("signResult".equals(request.getParameter("action"))){
        String signResult = request.getParameter("signResult");

    	System.out.printf("signResult: [%s]\n", signResult);
    	out.println("<hr/>signResult:<br/>");
    	out.println(signResult);
    	VpcgSignResult vpcgSignResult=null;
        try{
            vpcgSignResult = vpcgSignResultService.getSignResult(signResult);
            out.println("<hr/>signedData:<br/>");
            out.println(vpcgSignResult.getSignedData());

            out.println("<hr/>vidRandom:<br/>");
            out.println(vpcgSignResult.getVidRandom());

            out.println("<hr/>ci:<br/>");
            out.println(vpcgSignResult.getCi());

            out.println("<hr/>provider:<br/>");
            out.println(vpcgSignResult.getProvider());
            out.println("<hr/>signType:<br/>");
            out.println(vpcgSignResult.getSignType());
            out.println("<hr/>txId :<br/>");
            out.println(vpcgSignResult.getTxId());

            out.println("<hr/>completedAt:<br/>");
            out.println(vpcgSignResult.getCompletedAt());

            out.println("<hr/>rawResponse:<br/>");
            out.println(vpcgSignResult.getRawResponse());



        }catch(VpcgSignResultException e){
            e.printStackTrace();
            out.println("<hr/>errorCode:<br/>");
            out.println(e.getErrorCode());
            out.println("<hr/>getErrorMessage:<br/>");
            out.println(e.getErrorMessage());
            out.println("<hr/>getRawResponse:<br/>");
            out.println(e.getRawResponse());
        }

        //saveTxInfo
        if(vpcgSignResult!=null){
            try{
                String userId = "userId-1";
                String serviceCode = "svcCode-1";
                vpcgSignResultService.saveTxInfo(vpcgSignResult.getTxId(), userId, serviceCode);
                out.println("<hr/>saveTxInfo:<br/>");
                out.println(String.format("txId:%s, userId:%s, serviceCode:%s", vpcgSignResult.getTxId(), userId, serviceCode));
            }catch(VpcgSignResultException e){
                e.printStackTrace();
                out.println("<hr/>saveTxInfo.errorCode:<br/>");
                out.println(e.getErrorCode());
                out.println("<hr/>saveTxInfo.getErrorMessage:<br/>");
                out.println(e.getErrorMessage());
            }
        }

        return;
    }
%>
<!DOCTYPE HTML>
<html>
<head>
    <title>VeraPort CG</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <script src="../jquery/jquery-1.6.4.min.js"></script>
</head>
<body>

<h2>kakao/toss</h2>
<form id="request-sign">

    CI: <input type="text" name="userCi" value=''><br/>

    또는 <br/>

    전화번호: <input type="text" name="userPhone" value=''><br/>
    이름: <input type="text" name="userName" value=''><br/>
    생년월일(YYYYMMDD): <input type="text" name="userBirthday" value=''><br/>

    또는 <br/>
    Naver code : <input type="text" name="userAuthCode" value=''><br/>
    <hr/>

    원문: <textarea name="data" rows="4" cols="50">ABC가나다123</textarea><br/>

    원문타입: <select name='dataType'>
                  <option value='TEXT'>TEXT</option>
                  <option value='MARKDOWN'>MARKDOWN (kakao only)</option>
                  <option value='HTML'>HTML (toss only)</option>
              </select><br/>

    title: <input type="text" name="title" value='전자서명'><br/>
    triggerType : <select name='triggerType'>
        <option value='MESSAGE'>MESSAGE</option>
        <option value='SCHEME'>SCHEME</option>
    </select><br/>
    signType : <select name='signType'>
            <option value='AUTH'>AUTH</option>
            <option value='AUTH2'>AUTH2</option>
            <option value='LOGIN'>LOGIN</option>
            <option value='SIMPLE'>SIMPLE</option>
            <option value='CONFIRM'>CONFIRM</option>
    </select><br/>
    provider : <select name='provider'>
        <option value='kakao'>kakao</option>
        <option value='toss'>toss</option>
        <option value='naver'>naver</option>
        <option value='pass'>pass</option>
        <option value='payco'>payco</option>
    </select><br/>
</form>
<hr/>

<button onclick="config()">설정요청</button><br/>

<button onclick="preRequestSign()">서명요청</button><br/>

<form id="status-sign">
provider:<input type="text" name="provider" id="provider"><br/>
txId:<input type="text" name="txId" id="txId"><br/>
signType:<input type="text" name="signType" id="signType"><br/>
</form>
<button onclick="statusSign()">서명상태</button><br/>
<hr/>

<script type="text/javascript" language="javascript">
function fnSignResult() {
    var x = (window.screen.availWidth - 900) / 2;
    var y = (window.screen.availHeight - 740) / 2;
    var style = "top=" + y + ", left=" + x + ", width=900, height=740, resizable=1, scrollbars=0";
    window.open("", 'signResult' ,  style);
    
    var frm = document.getElementById('signForm');
    frm.action = location.pathname + "?action=signResult";
    frm.method = "post";
    frm.target = "signResult";
    frm.submit();      
}
</script>

<form method="post" id="signForm">
    signResult<input type="text" name="signResult" id="sign-result"><br/>
    <input type="button" value="signResult" onclick="javascript:fnSignResult();" >
</form>
<hr/>

app scheme: <a id="app-scheme" href=""></a>
<hr/>

서명요청 결과
<div id="req-result" style="width:600px"></div>
<hr/>

상태요청 결과
<div id="status-result" style="width:600px"></div>

<hr/>
<button onclick="clearResult()">clear</button><br/>
<hr/>

<script type="text/javascript" language="javascript">
    function setDefaultUser(userPhone, userName, userBirthday) {
        document.getElementById("request-sign").userPhone.value = userPhone;
        document.getElementById("request-sign").userName.value = userName;
        document.getElementById("request-sign").userBirthday.value = userBirthday;
    }
    
    if (!window.origin) window.origin = window.location.protocol + "//" + window.location.hostname + (window.location.port ? ':' + window.location.port: '');
    var VPCG_SERVICE = "../svc/delfino_vpcgRequest.jsp?origin=" + encodeURIComponent(origin);
    var VPCG_NAVER = VPCG_SERVICE + "&provider=naver";
    var vpcgWin = null;

    function requestAuthNaver(){
        vpcgWin = window.open(VPCG_NAVER + "&action=requestAuth", "vpcgNaverWin", "width=500, height=600");
    }

    function preRequestSign(){
        if($('#request-sign [name="provider"]').val() == "naver" && $('#request-sign [name="triggerType"]').val() == "MESSAGE"){
            requestAuthNaver();
        }
        else{
            requestSign();
        }
    }

    function config(){
        var params = {nonce : "12345678901234567890"};
        var jqxhr = $.get(VPCG_SERVICE + "&action=config", params, function(result) {
            console.log(result);
            alert(JSON.stringify(result))
        }, "json")
        .fail( function(result) {
            console.log(result);
            alert(result.responseText);
        });
    }

    function requestSign(){
        $("#req-result").html("");
        $("#txId").val("");
        $("#provider").val("");

        $("#app-scheme").attr("href", "#");
        $("#app-scheme").html("");

        var params = $("#request-sign").serialize();

        var jqxhr = $.post(VPCG_SERVICE + "&action=requestSign", params, function(result) {
            console.log(result);

            if(result.error){
                $("#req-result").html('<span style="color: red">' + JSON.stringify(result) + '</span>');

                if(result.error.provider=="naver" && result.error.code=="not_allowed_client"){
                    vpcgWin = window.open(VPCG_NAVER + "&action=requestAuth&auth_type=reprompt", "vpcgNaverWin", "width=500, height=600");
                }

                return;
            }

            $("#req-result").html('<span style="color: blue">' + JSON.stringify(result) + '</span>');

            $("#txId").val(result.txId);
            $("#provider").val(result.provider);
            $("#signType").val(result.signType);

            if(result.provider == "kakao"){
                var appScheme = "kakaotalk://kakaopay/cert/sign?tx_id=" + result.txId;
                $("#app-scheme").attr("href", appScheme);
                $("#app-scheme").html(appScheme);
            }
            if(result.provider == "toss"){
                var type= (result.signType=="LOGIN" ||result.signType=="AUTH")? "user" : "doc";

                var appScheme = "supertoss://tossCert/sign/"+type+" ?_minVerIos=4.84.0&_minVerAos=4.84.0&callbackUrl=veraportcgoc://verportcg/toss&txId=" + result.txId;
                $("#app-scheme").attr("href", appScheme);
                $("#app-scheme").html(appScheme);
            }
            if(result.provider == "naver" && result.pollingPageUrl){
                vpcgWin = window.open(result.pollingPageUrl, "vpcgNaverWin", "width=500, height=600");
            }
        }, "json")
        .fail( function(result) {
            try{
                var responseJSON = JSON.parse(result.responseText);
                $("#req-result").html('<span style="color: red">' + JSON.stringify(responseJSON) + '</span>');
                if(responseJSON.error && responseJSON.error.provider=="naver" &&
                (responseJSON.error.code=="not_allowed_client" || responseJSON.error.code=="empty_ci_profile")){
                    vpcgWin = window.open(VPCG_NAVER + "&action=requestAuth&auth_type=reprompt", "vpcgNaverWin", "width=500, height=600");
                }
            }catch(e){
                console.error(e);
                $("#req-result").html('<span style="color: red">' + result.responseText + '</span>');
            }
        });
    }

    function statusSign(){
        $("#status-result").html("");
        $("#sign-result" ).val("");

        var params = $("#status-sign").serialize() ;
        params += "&action=statusSign";
        params += "&dummy=" + new Date().getTime();

        $.get(VPCG_SERVICE, params, function(result) {
                console.log(result);
                $("#status-result").html('<span style="color: blue">' + JSON.stringify(result) + '</span>');
				if(result.status === "COMPLETED"){
					$("#sign-result").val(JSON.stringify(result));
				}
            }, "json")
            .fail( function(result) {
                $("#status-result").html('<span style="color: red">' + result.responseText + '</span>');
            });
    }
    function clearResult(){
        $("#req-result").html("");
        $("#txId").val("");
        $("#provider").val("");

        $("#status-result").html('');
        $("#sign-result" ).val("");

        $("#app-scheme").attr("href", "#");
        $("#app-scheme").html("");
    }

    function VPCGPostMessage(result){
        console.log(result);

        if(result.error){
            $("#req-result").html('<span style="color: red">' + JSON.stringify(result) + '</span>');
            if(vpcgWin!=null) vpcgWin.close();
            vpcgWin = null;
            return;
        }
        $("#req-result").html('<span style="color: blue">' + JSON.stringify(result) + '</span>');

        if(result.action == 'authCallback'){
             $('#request-sign [name="userAuthCode"]').val(result.code);
             requestSign();
             return;
        }

        if(result.action == 'signCallback'){
            if(vpcgWin!=null) vpcgWin.close();
            vpcgWin = null;

            $("#sign-result").val(JSON.stringify(result));
        }
    }
</script>
</body>
</html>