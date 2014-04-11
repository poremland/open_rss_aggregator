function FeedItemDisplay(baseUrl, container, feedList)
{
	this.root_url = baseUrl;
	this.feedId = -1;
	this.feedItemId = -1;
	this.title = "";
	this.link = "";
	this.date = new Date();
	this.description = "";
	this.container = container;
	this.feedList = feedList;
	this.currentTop = 0;
	this.isDragging = false;
	this.markAsReadHandlers = new Array();
}

FeedItemDisplay.prototype.AddMarkAsReadHandler = function(callback)
{
	this.markAsReadHandlers.push(callback);
}

FeedItemDisplay.prototype.DisplayTextContents = function(text)
{
	context.description = text;
	context.DisplayLightBox();
}

FeedItemDisplay.prototype.DisplayHtmlContents = function(contentUrl)
{
	var context = this;
	$.ajax({
		type: "GET",
		url: contentUrl,
		error: function(response) {	alert("Unable to access: " + contentUrl); },
		success: function(response)
		{	
			context.description = response;
			context.DisplayLightBox();
		}
	});
}

FeedItemDisplay.prototype.DisplayFeedItem = function(item)
{
	this.isDragging = false;
	this.title = item.title;
	this.link = item.link;
	this.feedId = item.feed_id;
	this.feedItemId = item.id;
	this.date = new Date(item.updated_at);
	this.description = item.description;

	this.DisplayLightBox();
}

FeedItemDisplay.prototype.DisplayLightBox = function()
{
	this.GreyOutBackground();
	this.AddContentToLightBox();
	this.AddCloseButtonToLightBox();
	this.AnimateOpeningOfLightBox();
}

FeedItemDisplay.prototype.GetStartingLightBoxCSS = function()
{
	var screenWidth = $(document).width();
	var screenHeight = $(window).height();
	return {'width':0,'height':0,'left':screenWidth/2,'top':screenHeight/2};
}

FeedItemDisplay.prototype.GetEndingLightBoxCSS = function()
{
	var screenWidth = $(document).width();
	var screenHeight = $(window).height();
	var width = screenWidth * .65;
	var height = screenHeight * .75;
	var left = (screenWidth - width) / 2;
	var top = (screenHeight - height) / 2 + window.pageYOffset;

	return {'width':width,'height':height,'left':left,'top':top};
}

FeedItemDisplay.prototype.GreyOutBackground = function()
{
	this.feedList.css({ opacity: 0.2 });
	$('body').css({'overflow':'hidden'});
}

FeedItemDisplay.prototype.AddContentToLightBox = function()
{
	var content = $("<div class='LightBoxInnerContent'>");
	content.html("");
	content.append("<a href='" + this.link + "' target='blank'>" + this.title + "</a><br/><br/>");
	content.append(this.description);
	content.disableSelection();

	this.container.append(content);
	this.container.corner();
}

FeedItemDisplay.prototype.AddCloseButtonToLightBox = function()
{
	var context = this;
	var hideButton = $("<div class='LightBoxHideButton'>_</div>");
	var closeButton = $("<div class='LightBoxCloseButton'>X</div>");
	hideButton.click(function(){ context.HideLightBoxDescription(); });
	closeButton.click(function(){ context.MarkFeedAsRead(context.feedId, context.feedItemId); });
	this.container.append(hideButton);
	this.container.append(closeButton);
}

FeedItemDisplay.prototype.AnimateOpeningOfLightBox = function()
{
	var starting = this.GetStartingLightBoxCSS();
	var ending = this.GetEndingLightBoxCSS();
	this.container.css(starting);
	this.container.css({"display":"block"});
	this.container.animate(ending, 1000, function() { });
}

FeedItemDisplay.prototype.AnimateClosingOfLightBox = function(callback)
{
	var ending = this.GetStartingLightBoxCSS();
	var starting = this.GetEndingLightBoxCSS();
	this.container.css(starting);
	this.container.css({"display":"block"});
	this.container.animate(ending, 500, callback);
}

FeedItemDisplay.prototype.HideLightBoxDescription = function()
{
	var context = this;
	this.AnimateClosingOfLightBox(function(){
		context.container.html("");
		context.container.css({"display": "none"});
		$('body').css({'overflow':'auto'});
		context.feedList.css({ opacity: 1.0 });
	});
}

FeedItemDisplay.prototype.MarkFeedAsRead = function(feedId, feedItemId)
{
	var context = this;
	var div = $("#FeedItem" +  feedItemId);

	$.ajax({
		type: "GET",
		url: this.root_url + "/feed_items/mark_as_read/" + feedItemId + ".xml",
		error: function(response) {	alert("Unable to mark the feed item as read"); },
		success: function(response)
		{
			for(var index=0;index<context.markAsReadHandlers.length;index++)
			{
				context.HideLightBoxDescription();
				context.markAsReadHandlers[index](feedId, feedItemId);
			}
		}
	});
}
