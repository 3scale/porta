/*global jQuery */
/*jslint white: true, browser: true, onevar: true, undef: true, nomen: true, eqeqeq: true, bitwise: true, regexp: true, newcap: true, strict: true */
/**
 * jQuery plugin for posting form including file inputs.
 * 
 * Copyright (c) 2010 Ewen Elder
 *
 * Licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 * @author: Ewen Elder <glomainn at yahoo dot co dot uk> <ewen at jainaewen dot com>
 * @version: 1.0.1 (2010-07-22)
**/

'use strict';
(function ($)
{
	$.fn.iframePostForm = function (options)
	{
		var contents, elements, element, iframe;
		
		elements = $(this);
		options = $.extend({}, $.fn.iframePostForm.defaults, options);
		
		// Add the iframe.
		if (!$('#' + options.iframeID).length)
		{
			$('body').append('<iframe name="' + options.iframeID + '" id="' + options.iframeID + '" style="display:none"></iframe>');
		}
		
		
		return elements.each
		(
			function ()
			{
				element = $(this);
				
				
				// Target the iframe.
				element.attr('target', options.iframeID);
				
				
				// Submit listener.
				element.submit
				(
					function ()
					{
						options.post.apply(this);
						
						iframe = $('#' + options.iframeID);
						iframe.one
						(
							'load',
							function ()
							{
								contents = iframe.contents().find('body');
								options.complete.apply(this, [contents.html()]);
								
								setTimeout
								(
									function ()
									{
										contents.html('');
									},
									1
								);
							}
						);
					}
				);
			}
		);
	};
	
	
	$.fn.iframePostForm.defaults = {
		iframeID : 'iframe-post-form',       // IFrame ID.
		post : function () {},               // Form onsubmit.
		complete : function (response) {}    // After everything is completed.
	};
})(jQuery);