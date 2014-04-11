String.prototype.ScrubHtml = function(){
	return this.replace(/(<([^>]+)>)/ig,"");
}
