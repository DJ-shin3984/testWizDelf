<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, width=device-width" />
		<title>복합전자 서명</title>
<%@ include file="../svc/delfino.jsp" %>		
    </head>
    <body> 
    	<h2>복합전자 서명</h2>
    	한번의 패스워드 입력으로 여러개의 서명(PKCS7 + mdSign)값을 생성 하고 싶은 경우 사용된다.<br/>
    	서버에서는 여러개를 각각 잘라내 PKCS7값과 mdSign값을 검증해야한다. <br/>
		<form name="delfinoForm" method="post" action="complexSignAction.jsp">
			<input type="hidden" name="PKCS7">
			<input type="hidden" name="VID_RANDOM">
			<input type="hidden" name="dataType" value="complex"/>
			<input type="hidden" name="etc2" value="12345"/>
		</form>
		
		<button onclick="complexSign()">서명 </button>
		<script>
			function complete(result){
				if(result.status==0) {
					alert("error:" + result.message + "[" + result.code + "]");
					return;}
				if(result.status==1){
					console.log(JSON.parse(result.signData));
					document.delfinoForm.PKCS7.value = result.signData;
					document.delfinoForm.VID_RANDOM.value = result.vidRandom;
					document.delfinoForm.submit();
				}
				else{
					alert("error:" + result.message + "[" + result.code + "]");
				}
			}
			
			function complexSign(){
				var signData = [];
				signData.push({tag:'sign_1',dataType:'string',data:'sign_data_1'});
				signData.push({tag:'sign_2',dataType:'string',data:'sign_data_2'});
				signData.push({tag:'md_sign_1',dataType:'sha256-md',data:'md_sign_data_1'});
				signData.push({tag:'sign_3',dataType:'string1',data:'sign_data_3'});
				signData.push({tag:'md_sign_2',dataType:'sha256-md',data:'md_sign_data_2'});
				signData.push({tag:'sign_4',dataType:'string',data:'sign_data_4'});
				signData.push({tag1:'sign_4',dataType2:'string',data3:'sign_data_4'});

				var data = JSON.stringify(signData);
				Delfino.complexSign(data, complete);
			}
		</script>
		
	</body>
</html>