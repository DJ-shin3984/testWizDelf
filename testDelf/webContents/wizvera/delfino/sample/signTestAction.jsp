<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.wizvera.crypto.PKCS7Verifier" %>
<%@ page import="com.wizvera.crypto.CertificateVerifier" %>
<%@ page import="java.security.cert.X509Certificate" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=euc-kr" />
		<meta name="viewport" content="width=device-width" />
		<title>서명 test</title>
		
<%@ include file="../svc/delfino.jsp" %>		

    </head>


<body>

<%
	String pkcs7 = request.getParameter(PKCS7Verifier.PKCS7_NAME);
	String vid = request.getParameter(CertificateVerifier.VID_RANDOM_NAME);
	String pkcs7Dump = com.wizvera.crypto.PKCS7Dump.dumpAsString(pkcs7);
%>


<%	
	PKCS7Verifier p7helper=null;
	try {
		String encoding = request.getCharacterEncoding();
		p7helper = new PKCS7Verifier(pkcs7,"euc-kr");


		
		X509Certificate cert = p7helper.getSignerCertificate();
		
		out.println("<br/><br/> Certificate issuer:" + cert.getIssuerX500Principal().getName());
		out.println("<br/> Certificate subject:" + cert.getSubjectX500Principal().getName());
		out.println("<br/> Certificate Serial Number:" + cert.getSerialNumber());
		out.println("<br/><br/>");

	} catch (Exception e) {
		out.println("<p/>");
		out.println("Error Occured:" + e.toString());
		out.println("pkcs7:" + pkcs7);
		out.println("pkcs7 dump:<br/><pre>");
		out.println(pkcs7Dump);
		out.println("</pre>");
		out.println("<p/>");
		e.printStackTrace();
	}

%>
<%if(p7helper!=null){ %>

전자서명원문데이터:<%=p7helper.getSignedRawData()%>
<br/><br/>
PKCS7:<%=pkcs7%><br/>
<p/>
PKCS7:
<pre>
<%=pkcs7Dump%>
</pre>

<%} %>
<br/>
<a href="index.jsp"> 처음으로 </a>
</body>
</html>