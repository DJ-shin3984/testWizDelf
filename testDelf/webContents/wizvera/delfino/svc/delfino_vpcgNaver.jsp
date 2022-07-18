<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
%><%@ page import="com.wizvera.vpcg.NaverController"
%><%@ page import="java.util.*"
%><%!
    NaverController naverController = new NaverController();
%>
<%
    java.text.DateFormat logDate = new java.text.SimpleDateFormat("[yyyy/MM/dd HH:mm:ss] ");
    System.out.println(logDate.format(new java.util.Date()) + "[VPCG-NAVER] action:" + request.getParameter("action"));
    naverController.doService(request, response, session);
%>
