function Application(baseUrl) {
  this.baseUrl = baseUrl;
}

Application.prototype.Initialize = function() {
    $('#feedContent').corner();
}

Application.prototype.AddButtonEvents = function() {
  var baseUrl = this.baseUrl;

  $("#logoutButton").bind("click", function(e) {
    $.ajax({
      type: "GET",
      url: baseUrl + "/login/do_logout",
      success: function(response){
        location.reload( true );
      }
    });
  });

  $("#refreshButton").bind("click", function(e) {
		feedList.GetFeeds();
  });

  $("#addFeedButton").bind("click", function(e) {
		feedItemDisplay.DisplayHtmlContents(baseUrl + "/feeds/new");
    return false;
  });
}
