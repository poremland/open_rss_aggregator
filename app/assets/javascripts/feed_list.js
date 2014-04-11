function FeedList(root_url, user_id, container)
{
  this.root_url = root_url;
  this.user_id = user_id;
	this.container = container;
	this.displayHandlers = new Array();
	this.textHandlers = new Array();
	this.isDragging = false;
	this.currentLeft = 0;
	this.feedItems = new Array();
}

FeedList.prototype.AddDisplayHandler = function(callback)
{
	this.displayHandlers.push(callback);
}

FeedList.prototype.AddTextHandler = function(callback)
{
	this.textHandlers.push(callback);
}

FeedList.prototype.GetFeeds = function()
{
	var context = this;
	this.container.html("");
	var url = this.root_url + "/feeds/tree.json";
	$.getJSON(url, function(data) { context.DisplayFeeds(data); });
}

FeedList.prototype.DisplayFeeds = function(feeds)
{
	var feedsWithItems = 0;
	var context = this;
	$.each(feeds, function(key, val)
	{
		var feed = val.feed;
		if(feed.count > 0)
		{
			feedsWithItems++;
			var ribbon = context.CreateFeedRibbon(feed);
			context.container.append(ribbon);
		}
	});

	if(feedsWithItems == 0)
	{
		var ribbon = this.CreateNoUnreadFeedsRibbon();
		context.container.append(ribbon);
	}
}

FeedList.prototype.CreateNoUnreadFeedsRibbon = function(feed)
{
	var content = $("<div id='FeedRibbonContent' class='NoUnReadFeedsRibbonContent'>");
	content.append("There are no feeds with unread items");
	var ribbon = $("<div id='FeedRibbon' class='NoUnReadFeedsRibbon'>");
	ribbon.append(content);
	return ribbon;
}

FeedList.prototype.CreateFeedRibbon = function(feed)
{
	var items = $("<div id='FeedRibbonContent" + feed.id + "' class='FeedRibbonContent'>");
	var buttons = this.CreateFeedButtons(feed);
	this.AddDragEvents(items);

	var ribbon = $("<div id='FeedRibbon" + feed.id + "' class='FeedRibbon'>");
	ribbon.append(items);
	ribbon.append(buttons);

	var context = this;
	var url = this.root_url + "/feeds/" + feed.id + ".json";
	$.getJSON(url, function(data) { context.AddFeedItemsToRibbon(items, feed.id, data); });

	return ribbon;
}

FeedList.prototype.AddDragEvents = function(item)
{
	var context = this;
	item.mousedown(function(event) { context.isDragging = true; context.currentLeft = event.pageX; });
	item.mouseup(function() { context.isDragging = false; });
	item.mouseout(function() { context.isDragging = false; });
	item.mousemove(function(event)
	{
		if(context.isDragging)
		{
			var cssTop = parseInt(item.css("left"));
			var current = (cssTop + "" == "NaN") ? 0 : cssTop;
			if(event.pageX < context.currentLeft)
			{
				item.css("left", current - (context.currentLeft - event.pageX));
			}
			else if(event.pageX > context.currentLeft && current < 0)
			{
				item.css("left", current + (event.pageX - context.currentLeft));
			}
			context.currentLeft = event.pageX;
		}
	});
}

FeedList.prototype.CreateFeedTitle = function(feed)
{
	var title = $("<div id='FeedTitle" + feed.id + "' class='FeedTitle'>");
	title.append(feed.name);
	return title;
}

FeedList.prototype.CreateFeedButtons = function(feed)
{
	var context = this;
	var buttonContainer = $("<div id='FeedRibbonButtons" + feed.id + "' class='FeedRibbonButtons'>");

	var title = this.CreateFeedTitle(feed);
	var markAllAsRead = $("<div id='FeedRibbonButtonsMarkAllAsRead" + feed.id + "' class='FeedRibbonButtonsMarkAllAsRead'>Mark As Read</div>");
	markAllAsRead.click(function() { context.MarkAllAsRead(feed.id); });
	var remove = $("<div id='FeedRibbonButtonsRemove" + feed.id + "' class='FeedRibbonButtonsRemove'>Remove</div>");
	remove.click(function() { context.RemoveFeed(feed.id); });

	buttonContainer.append(title);
	buttonContainer.append(markAllAsRead);
	buttonContainer.append(remove);

	return buttonContainer;
}

FeedList.prototype.RemoveFeed = function(feedId)
{
	var context = this;
	var remove = confirm("Do you really want to remove this feed?");

	if(remove)
	{
		$.ajax({
			type: "GET",
			url: this.root_url + "/feeds/remove/" + feedId,
			error: function(response) {	alert(JSON.stringify(response)); context.GetFeeds(); },
			success: function(response) {	context.GetFeeds(); }
		});
	}
}

FeedList.prototype.MarkAllAsRead = function(feedId)
{
	var context = this;
	var items = new Array();
	for(var index=0;index<this.feedItems[feedId].length;index++)
	{
		var item = this.feedItems[feedId][index];
		items.push(item.id);
	}

	$.ajax({
		type: "POST",
		beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
		data: {"items":items},
		url: this.root_url + "/feeds/mark_items_as_read/" + feedId,
		error: function(response) {	context.GetFeeds(); },
		success: function(response) {	context.GetFeeds(); }
	});
}

FeedList.prototype.AddFeedItemsToRibbon = function(itemContainer, feedId, items)
{
	this.feedItems[feedId] = new Array();
	var ribbon = $("<div id='FeedRibbonItems" + feedId + "' class='FeedRibbonItems'>");
	ribbon.disableSelection();
	itemContainer.append(ribbon);
	var context = this;
	$.each(items, function(key, val)
	{
		var feedItem = val;
		var item = context.CreateFeedItem(feedItem);
		context.SetupFeedItemEvents(item, feedItem);
		$(item).corner();
		ribbon.append(item);
		context.feedItems[feedId].push(feedItem);
	});
}

FeedList.prototype.CreateFeedItem = function(feedItem)
{
	var context = this;
	var date = new Date(feedItem.updated_at);
	var item = $("<div id='FeedItem" + feedItem.id + "' class='FeedItem'>");
	var title = $("<div id='FeedItemTitle" + feedItem.id + "' class='FeedItemTitle'>");
	title.append(feedItem.title);

	var timestamp = $("<div id='FeedItemTimestamp" + feedItem.id + "' class='FeedItemTimestamp'>");
	timestamp.append(date.toLocaleDateString());

	var description = $("<div id='FeedItemDescription" + feedItem.id + "' class='FeedItemDescription'>");
	description.append(feedItem.description);

	var button = $("<div class='FeedItemCloseButton'>X</div>");
	button.click(function(){ context.MarkFeedAsRead(feedItem.feed_id, feedItem.id); });
	button.corner();

	item.append(title);
	//item.append(timestamp);
	item.append(description);
	item.append(button);

	return item;
}

FeedList.prototype.SetupFeedItemEvents = function(item, feed)
{
	var context = this;
	$(item).dblclick(function() {
		context.Display(feed);
	});
}

FeedList.prototype.Display = function(feed)
{
	for(var index=0;index<this.displayHandlers.length;index++)
	{
		this.displayHandlers[index](feed);
	}
}

FeedList.prototype.FeedMarkedAsRead = function(feedId, feedItemId)
{
	this.FeedItemRemoved(feedId, feedItemId);
	var div = $("#FeedItem" +  feedItemId);
	div.hide();
}

FeedList.prototype.FeedItemRemoved = function(feedId, feedItemId)
{
	var count = this.feedItems[feedId].length;
	for(var index=0;index<count;index++)
	{
		var item = this.feedItems[feedId][index];
		if(item.id == feedItemId)
		{
			this.feedItems[feedId].splice(index, 1);
			index = count;
		}
	}
}

FeedList.prototype.MarkFeedAsRead = function(feedId, feedItemId)
{
	var context = this;
	var div = $("#FeedItem" +  feedItemId);

	$.ajax({
		type: "GET",
		url: this.root_url + "/feed_items/mark_as_read/" + feedItemId + ".xml",
		error: function(response) {	alert("Unable to mark the feed item as read"); },
		success: function(response)
		{
			context.FeedItemRemoved(feedId, feedItemId);
			div.hide();
		}
	});
}
