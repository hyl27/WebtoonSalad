<%@ page language="java" contentType="text/html; charset=UTF-8"   pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec"%>
<!DOCTYPE html>
<html lang="ko">
<head>
   <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/jjim.css?version=${System.currentTimeMillis()}">
</head>
<body>
   <jsp:include page="/WEB-INF/views/header.jsp" />
   <main>
   <jsp:include page="/WEB-INF/views/leftaside.jsp" />
   <section class="jjim-list">
       <h1><span class="user-name">${userName}</span> 님의 <span class="jjim-text">찜</span>한 웹툰</h1>
       <div class="user-search-bar">
          <input type="text" id="userSearchInput" placeholder="👥 친구 찜꽁 구경하기">
          <div class="results" id="userSearchResults"></div>
      </div>
       <c:if test="${not empty jjims}">
           <div id="webtoon-items">
               <c:forEach var="webtoon" items="${jjims}">
                  <div class="webtoon-item ${webtoon.isViewed == 1 ? 'viewed' : ''}" data-webtoon-id="${webtoon.webtoonId}">
                       <a href="${webtoon.url}" target="_blank" class="webtoon-link" onclick="updateLastView('${userId}', '${webtoon.webtoonId}')">
                           <div class="thumbnail-container">
                               <img src="${webtoon.thumbnail1}" alt="${webtoon.title} thumbnail 1" />
                               <c:if test="${not empty webtoon.thumbnail2}">
                                   <img src="${webtoon.thumbnail2}" alt="${webtoon.title} thumbnail 2" />
                               </c:if>
                           </div>
                          <div class="webtoon-details">
                          <div class="up_title">
                             <p class="webtoon-title">${webtoon.title}</p>
                             <c:choose>
                                    <c:when test="${webtoon.isUpdated == 1}">
                                        <div class="is-updated">🆙</div>
                                    </c:when>
                                  <c:otherwise> </c:otherwise>
                              </c:choose>
                          </div>
                              <div class="webtoon-info">
                                  <p>연재 요일 | ${webtoon.updateDays}</p>
                                  <p>최근 업로드 일자 | ${webtoon.lastUp}</p>
                                  <p>마지막으로 본 날짜 | 
                               <c:choose>
                                   <c:when test="${webtoon.lastView == null}">
                                       미열람
                                   </c:when>
                                   <c:otherwise>
                                       ${webtoon.lastView}
                                   </c:otherwise>
                               </c:choose>
                           </p>
                                  <div class="jjim-count">❤️ ${webtoon.jjimCount}</div>
                              </div>
                          </div>
                       </a>

                       <div class="webtoon-buttons">
                           <button class="detail-button" onclick="location.href='${pageContext.request.contextPath}/webtoon/detail?id=${webtoon.webtoonId}'">웹툰 정보</button>
                           <sec:authorize access="principal.username eq '${userId}'">
                               <button class="delete-button" onclick="deleteJJim('${userId}', '${webtoon.webtoonId}')">🗑</button>
                           </sec:authorize>
                           <sec:authorize access="principal.username ne '${userId}'">
                          <button class="delete-button" style="visibility: hidden;">🗑</button>
                      </sec:authorize>
                       </div>
                   </div>
               </c:forEach>
           </div>
       </c:if>
       <c:if test="${empty jjims}">
           <p>찜한 웹툰이 없습니다.</p>
       </c:if>
       <c:if test="${not empty error}">
           <p class="error">${error}</p>
       </c:if>
   </section>
   		<jsp:include page="/WEB-INF/views/rightaside.jsp" />
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
   </main>
   <jsp:include page="/WEB-INF/views/footer.jsp" />
   
   <!-- sec:authentication 태그가 HTML 엔터티를 이스케이프하므로 먼저 값 할당 -->
    <sec:authentication property="name" var="loggedInUserId" />
    
   <script>
   // JSP에서 할당된 변수를 JavaScript에서 사용
   var loggedInUserId = '${loggedInUserId}';
   
   function deleteJJim(userId, webtoonId) {
      if (userId === loggedInUserId) {
         if (confirm("정말 삭제하시겠습니까?")) {
              $.ajax({
                  url: '${pageContext.request.contextPath}/jjim/delete',
                  type: 'GET',
                  data: { userId: loggedInUserId, webtoonId: webtoonId },
                  success: function(response) {
                      if (response === "success") {
                          alert("삭제되었습니다.");
                          location.reload();
                      } else {
                          alert("삭제에 실패했습니다.");
                      }
                  },
                  error: function() {
                     alert("삭제 중 오류가 발생했습니다. 상태: " + status + ", 오류: " + error);
                  }
              });
          }
      }
   }
   
    function updateLastView(userId, webtoonId) {
        $.ajax({
            url: '${pageContext.request.contextPath}/jjim/updateLastView',
            type: 'POST',
            data: { 
                userId: loggedInUserId, 
                webtoonId: webtoonId,
                _csrf: '${_csrf.token}' // CSRF 토큰 추가
            },
            success: function(response) {
                if (response === "success") {
                   if (userId === loggedInUserId)
                       reloadWebtoonList(userId); // 웹툰 목록을 다시 불러옵니다.
                } else {
                    alert("lastview 업데이트에 실패했습니다.");
                }
            },
            error: function(xhr, status, error) {
                alert("lastview 업데이트 중 오류가 발생했습니다. 상태: " + status + ", 오류: " + error);
            }
        });
    }

    function reloadWebtoonList(userId) {
        $.ajax({
            url: '${pageContext.request.contextPath}/jjim/list',
            type: 'GET',
            data: { userId: userId },
            success: function(response) {
            // 응답을 파싱하여 필요한 부분을 추출
                var tempDiv = $('<div>').html(response);
                var newContent = tempDiv.find('#webtoonItems').html();
                $('#webtoon-items').html(newContent);
            },
            error: function(xhr, status, error) {
                alert("웹툰 목록을 불러오는 중 오류가 발생했습니다. 상태: " + status + ", 오류: " + error);
            }
        });
    }
    
    $(document).ready(function() {
        let selectedIndex = -1;

        // 사용자 검색 함수
        function searchUser() {
            var keyword = document.getElementById('userSearchInput').value;

            if (keyword.length > 0) {
                $.ajax({
                    url: '${pageContext.request.contextPath}/user/search',
                    type: 'GET',
                    data: {
                        keyword: keyword
                    },
                    success: function(data) {
                        if (Array.isArray(data)) {
                            displayUserResults(data);
                        } else {
                            console.error('Received data is not an array');
                        }
                    },
                    error: function() {
                        console.error('사용자 검색 중 오류 발생');
                    }
                });
            } else {
                $('#userSearchResults').hide();
            }
        }

        // 검색 결과 표시 함수
        function displayUserResults(data) {
            var results = $('#userSearchResults');
            results.empty();
            if (data.length > 0) {
                data.forEach(function(item, index) {
                    var div = $('<div>').addClass('result-item').text(item.name);
                    div.on('click', function() {
                        window.location.href = '${pageContext.request.contextPath}/jjim?userId=' + item.id;
                    });
                    results.append(div);
                });
                results.show();
            } else {
                results.hide();
            }
        }

        // 키보드 이벤트 리스너
        $('#userSearchInput').on('keydown', function(e) {
            var results = $('#userSearchResults').children('.result-item');
            if (e.key === 'ArrowDown') {
                selectedIndex = (selectedIndex + 1) % results.length;
                results.removeClass('selected');
                $(results[selectedIndex]).addClass('selected');
            } else if (e.key === 'ArrowUp') {
                selectedIndex = (selectedIndex - 1 + results.length) % results.length;
                results.removeClass('selected');
                $(results[selectedIndex]).addClass('selected');
            } else if (e.key === 'Enter' && selectedIndex >= 0) {
                $(results[selectedIndex]).trigger('click');
            }
        });

        // 외부 클릭 시 결과창 닫기
        $(document).on('click', function(event) {
            if (!$(event.target).closest('#userSearchInput').length && !$(event.target).closest('#userSearchResults').length) {
                $('#userSearchResults').hide();
            }
        });

        // 검색창 클릭 시 결과창 표시
        $('#userSearchInput').on('focus', function() {
            if ($('#userSearchInput').val().length > 0) {
                $('#userSearchResults').show();
            }
        });

        // 검색창 입력 이벤트 리스너
        $('#userSearchInput').on('input', searchUser);
    });
   </script>
</body>
</html>