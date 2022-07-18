<%-- --------------------------------------------------------------------------
- File Name   : api-test.jsp
- Include     : none
- Author      : WIZVERA
- Last Update : 2022/05/02
-------------------------------------------------------------------------- --%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.net.*, java.io.*" %>
<%
    java.text.DateFormat logDate = new java.text.SimpleDateFormat("[yyyy/MM/dd HH:mm:ss] ");
    System.out.println(logDate.format(new java.util.Date())+request.getRequestURI()+" "+request.getMethod()+"[" + request.getRemoteAddr() + "]");
    request.setCharacterEncoding("UTF-8");

    String aws_service_url = getParameter(request, "aws_service_url", "https://api.certgate.io/v1/sign/request");
    String aws_access_token = getParameter(request, "aws_access_token", "76fa8a6724398916b377f020f793aa74613842ee1feb8d09f9f224973ecfd784");
    String aws_request_data = getParameter(request, "aws_request_data", "action=config&nonce=pDWKEX9S3psHaUeMp6AuRIN6Iu4DAfSL");
    //aws_request_data  = "action=requestSign&title=%EC%9D%B8%EC%A6%9D&dataType=TEXT&triggerType=MESSAGE&channelType=PC_WEB";
    //aws_request_data += "&signType=AUTH2&provider=toss&data=testData";
    //aws_request_data += "&userName=%EA%B9%80%EC%83%81%EA%B7%A0&userBirthday=19721128&userPhone=01035201278";

    String certapi_token_url = getParameter(request, "certapi_token_url", "https://t-certapi.yeskey.or.kr/oauth/2.0/api/token");
    //certapi_token_url = "http://127.0.0.1:8885/oauth/2.0/api/token";
    String certapi_server_id = getParameter(request, "certapi_server_id", "DE00040000");
    String certapi_client_id = getParameter(request, "certapi_client_id", "cc9d7462-7a74-4f76-b903-3e86401f2f27");
    String certapi_client_secret = getParameter(request, "certapi_client_secret", "0e9fd1dd-dfe4-4e9b-bce6-aeffa4e68a45");
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ko" xml:lang="ko">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>G10 API 테스트</title>
</head>
<body>

<h2>G10 AWS-VPCG 테스트 <font size=2><a href="./index.jsp">home</a></font></h2>
<form name="testAWSForm" method="post">
  <input type="hidden" name="_action" value="exec_aws"/>
  <ul>
    <li>service_url: <input type="text" name="aws_service_url" size="65" value="<%=aws_service_url%>" /></li>
    <li>access_token: <input type="text" name="aws_access_token" size="65" value="<%=aws_access_token%>" /></li>
    <li>request_data: <input type="text" name="aws_request_data" size="65" value="<%=aws_request_data%>" /></li>
  </ul>
  <input type="button" onclick="javascript:location.href=location.pathname;" value="초기화" />
  <input type="submit" value="AWS테스트"/>
</form>

<h2>금결원 CERT-API 테스트 <font size=2><a href="https://fidoweb.yessign.or.kr:3300/guide/api_guide.html" target="_yessign_guide">금결원API메뉴얼</a></font></h2>
<form name="testCertAPIForm" method="post">
  <input type="hidden" name="_action" value="exec_certapi"/>
  <ul>
    <li>token_url: <input type="text" name="certapi_token_url" size="50" value="<%=certapi_token_url%>" /></li>
    <li>server_id: <input type="text" name="certapi_server_id" size="50" value="<%=certapi_server_id%>" /></li>
    <li>client_id: <input type="text" name="certapi_client_id" size="50" value="<%=certapi_client_id%>" /></li>
    <li>client_secret: <input type="text" name="certapi_client_secret" size="50" value="<%=certapi_client_secret%>" /></li>
  </ul>
  <input type="button" onclick="javascript:location.href=location.pathname;" value="초기화" />
  <input type="submit" value="CertAPI테스트"/>
</form>

<%
    String _action = getParameter(request, "_action", "");
    if ("exec_certapi".equals(_action) || "exec_aws".equals(_action)) {
        String testUrl = "";
        String testData = "";
        out.println("\n<br/><hr/><b>Request Info</b>");
        if ("exec_aws".equals(_action)) {
            testUrl = aws_service_url;
            testData = aws_request_data;
            out.println("\n<br/> - access_token [" + aws_access_token + "]");
        } else if ("exec_certapi".equals(_action)) {
            testUrl = certapi_token_url;
            testData = "server_id=" + certapi_server_id + "&client_secret=" + certapi_client_secret + "&scope=ocsp&grant_type=client_credentials&reissue=n";
            out.println("\n<br/> - client_id [" + certapi_client_id + "]");
        }
        out.println("\n<br/> - testUrl [" + testUrl + "]");
        out.println("\n<br/> - testData [" + testData + "]");

        URL url = null;
        HttpURLConnection http = null;
        OutputStream os = null;
        InputStream is = null;
        ByteArrayOutputStream baos = null;
        int HTTP_readTimeout = 10000;
        int HTTP_connectTimeout = 10000;
        try {
            url = new URL(testUrl);
            http = (HttpURLConnection) url.openConnection();
            if (url.getProtocol().toLowerCase().equals("https")) {
                trustAllHosts();
                javax.net.ssl.HttpsURLConnection https = (javax.net.ssl.HttpsURLConnection) url.openConnection();
                //https.setHostnameVerifier(DO_NOT_VERIFY); //TODO
                http = https;
            } else {
                http = (HttpURLConnection) url.openConnection();
            }
            byte[] postData = testData.getBytes("UTF-8");

            if (HTTP_connectTimeout > 0) http.setConnectTimeout(HTTP_connectTimeout);
            if (HTTP_readTimeout > 0) http.setReadTimeout(HTTP_readTimeout);

            http.setDoInput(true);
            http.setDoOutput(true);
            http.setUseCaches(false);
            http.setRequestMethod("POST");
            http.setRequestProperty("content-type", "application/x-www-form-urlencoded");

            if ("exec_aws".equals(_action)) {
                http.setRequestProperty("Authorization", "Bearer " + aws_access_token);
            } else if ("exec_certapi".equals(_action)) {
                http.setRequestProperty("client_id", certapi_client_id);
            }
            //http.setRequestProperty("X-Forwarded-For", "175.193.45.78");

            os = http.getOutputStream();
            os.write(postData, 0, postData.length);

            int responseCode = http.getResponseCode();
            out.println("\n<br/><br/><b>Result Info</b>");
            out.println("\n<br/> - contentType [" + http.getContentType() + "]");
            if (responseCode == HttpURLConnection.HTTP_OK) {
                out.println("\n<br/> - responseCode [" + http.getResponseCode() + "] <b>OK</b>");
                is = http.getInputStream();
            } else {
                out.println("\n<br/> - responseCode [" + http.getResponseCode() + "] <b>FAIL</b>");
                is = http.getErrorStream();
            }
            baos = new ByteArrayOutputStream();
            byte[] byteBuffer = new byte[1024];
            int respLength = 0;
            while ((respLength = is.read(byteBuffer, 0, byteBuffer.length)) != -1) {
                baos.write(byteBuffer, 0, respLength);
            }
            String responseData = new String(baos.toByteArray(), "UTF-8");
            out.println("\n<br/> - responseData [" + responseData + "]");

        } catch (Exception e) {
            e.printStackTrace();
            out.println("\n<br/><hr/><b>Exception - ERR(?)</b>");
            out.println("\n<br/> - FileName: " + request.getServletPath());
            out.println("\n<br/> - getMessage: " + e.getMessage());
            java.io.StringWriter sw = new java.io.StringWriter();
            java.io.PrintWriter pw = new java.io.PrintWriter(sw);
            e.printStackTrace(pw);
            out.println("\n<br><br><b>printStackTrace</b><br>");
            out.println("<font size='2'>" + sw.toString().replaceAll("\n", "\n<br/>&nbsp;") + "<font>");
        } finally {
            if (baos != null) try { baos.close(); } catch (Exception e) {};
            if (is != null)   try { is.close();   } catch (Exception e) {};
            if (os != null)   try { os.close();   } catch (Exception e) {};
            if (http != null) try { http.disconnect(); } catch (Exception e) { };
        }
    }
%>
<%!
    public static String getParameter(HttpServletRequest request, String name, String defaultValue) {
        String value = request.getParameter(name);
        if (value == null || "".equals(value)) value = defaultValue;
        return value;
    }
    private static void trustAllHosts() throws Exception {
        //Create a trust manager that does not validate certificate chains
        javax.net.ssl.TrustManager[] trustAllCerts = new javax.net.ssl.TrustManager[] { new javax.net.ssl.X509TrustManager() {
            public java.security.cert.X509Certificate[] getAcceptedIssuers() {
                return new java.security.cert.X509Certificate[] {};
            }
            public void checkClientTrusted(java.security.cert.X509Certificate[] chain, String authType) throws java.security.cert.CertificateException {
            }
            public void checkServerTrusted(java.security.cert.X509Certificate[] chain, String authType) throws java.security.cert.CertificateException {
            }
        }};
        //Install the all-trusting trust manager
        try {
            //javax.net.ssl.SSLContext sc = javax.net.ssl.SSLContext.getInstance("TLS");
            javax.net.ssl.SSLContext sc = javax.net.ssl.SSLContext.getInstance("TLSv1.2");
            sc.init(null, trustAllCerts, new java.security.SecureRandom());
            javax.net.ssl.HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
        } catch (Exception e) {
            e.printStackTrace();
            throw new Exception(e.getMessage(), e);
        }
    }
    final static javax.net.ssl.HostnameVerifier DO_NOT_VERIFY = new javax.net.ssl.HostnameVerifier() {
        public boolean verify(String hostname, javax.net.ssl.SSLSession session) {
            return true;
        }
    };
%>
<br/><hr/>
</body>
</html>
