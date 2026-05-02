<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="org.json.JSONObject, javax.servlet.http.HttpSession" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    JSONObject json = new JSONObject();
    HttpSession existingSession = request.getSession(false);

    json.put("app_build_marker", "session-diagnostics-2026-05-02-profile-route-check");
    json.put("has_session", existingSession != null);
    json.put("requested_session_id", request.getRequestedSessionId() == null ? JSONObject.NULL : request.getRequestedSessionId());
    json.put("requested_session_id_valid", request.isRequestedSessionIdValid());
    json.put("session_from_cookie", request.isRequestedSessionIdFromCookie());
    json.put("session_from_url", request.isRequestedSessionIdFromURL());

    if (existingSession != null) {
        json.put("session_id", existingSession.getId());
        json.put("admin_id", existingSession.getAttribute("admin_id") == null ? JSONObject.NULL : existingSession.getAttribute("admin_id").toString());
        json.put("admin_role", existingSession.getAttribute("admin_role") == null ? JSONObject.NULL : existingSession.getAttribute("admin_role").toString());
        json.put("user_id", existingSession.getAttribute("user_id") == null ? JSONObject.NULL : existingSession.getAttribute("user_id").toString());
        json.put("user_role", existingSession.getAttribute("user_role") == null ? JSONObject.NULL : existingSession.getAttribute("user_role").toString());
    }

    out.print(json.toString());
%>
