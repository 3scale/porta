// Functions dealing with provider side control of site colours. Probably to be deprecated with the
// development of CMS system

jQuery.noConflict();

var settings = function() {
    // var B = ["background_color", "text_color", "link_color", "sidebar_fill_color", "sidebar_border_color"];
    var A = {
        updateColors: function() {
            var E = jQuery("#settings_bg_colour").val();
            var G = jQuery("#settings_text_colour").val();
            var F = jQuery("#settings_link_colour").val();
            var C = jQuery("#settings_menu_bg_colour").val();
						var D = jQuery("#settings_menu_link_colour").val();
						var H = jQuery("#settings_content_bg_colour").val();
						var J = jQuery("#settings_plans_tab_bg_colour").val();
						var K = jQuery("#settings_content_border_colour").val();
						
            jQuery("#previewContent").css({"background-color": E, color: G});

						jQuery('#pBox span').css("color", G);
						jQuery('#pBox  span a').css("color", F);
						jQuery('#pLinks span.active').css("background-color", H);
						jQuery('#pLinks span').css("color", D);
						jQuery('#pBox, #pFooter').css("background-color", H);
						jQuery('#pBox, #pFooter').css("border-color", K);
						jQuery('#previewPlans table th.head').css("background-color", J);
						
            jQuery("#pMenu").css({
                "background-color": C
            });
        },
        synchColors: function(D) {
            var C = settings.colorPicker.linked;
            if (C && C.value && C.value != settings.colorPicker.color) {
                C.value = settings.colorPicker.color;
                jQuery(C).css({
                    "background-color": C.value,
                    color: settings.colorPicker.hsl[2] > 0.5 ? "#000": "#fff"
                });
                settings.updateColors()
            }
        },
        initDesignSettings: function() {

          jQuery("#linkDesign a").click(function() {
              jQuery("#designSettings").show();
							jQuery('#detailSettings').hide();
              jQuery("#linkDetails a").removeClass("active");
              jQuery("#linkDesign a").addClass("active");
              jQuery("#linkDetails").removeClass("active");
              jQuery("#linkDesign").addClass("active");
							
              return false
          });

          jQuery("#linkDetails a").click(function() {
              jQuery("#designSettings").hide();
							jQuery('#detailSettings').show();

              // jQuery("#backgrounds").hide();
              jQuery("#linkDetails a").addClass("active");
              jQuery("#linkDesign a").removeClass("active");
              jQuery("#linkDetails").addClass("active");
              jQuery("#linkDesign").removeClass("active");

              // if (jQuery("#colors").css("display") == "none") {
              //     jQuery("#title_picker").removeClass("active");
              //     jQuery("#title_background").removeClass("inactive")
              // } else {
              //     jQuery("#title_picker").addClass("active");
              //     jQuery("#title_background").addClass("inactive")
              // }
              // if (jQuery("#user_profile_default").val()) {
              //     jQuery("#user_profile_default").val(false)
              // }
              return false
          });

            jQuery("#title_picker a").click(function() {
                jQuery("#colors").toggle();
                jQuery("#backgrounds").hide();
                jQuery("#title_background").removeClass("active");
                if (jQuery("#colors").css("display") == "none") {
                    jQuery("#title_picker").removeClass("active");
                    jQuery("#title_background").removeClass("inactive")
                } else {
                    jQuery("#title_picker").addClass("active");
                    jQuery("#title_background").addClass("inactive")
                }
                if (jQuery("#user_profile_default").val()) {
                    jQuery("#user_profile_default").val(false)
                }
                return false
            });
            jQuery("#title_background a").click(function() {
                jQuery("#backgrounds").toggle();
                jQuery("#colors").hide();
                jQuery("#title_picker").removeClass("active");
                if (jQuery("#backgrounds").css("display") == "none") {
                    jQuery("#title_background").removeClass("active");
                    jQuery("#title_picker").removeClass("inactive")
                } else {
                    jQuery("#title_background").addClass("active");
                    jQuery("#title_picker").addClass("inactive")
                }
                return false
            });
            jQuery("#themes a").click(function() {
                var E = jQuery(this).attr("id");
                settings.setTheme(E.substring(5));
                return false
            });
            jQuery("#backgrounds a").click(function() {
                jQuery("#backgrounds a").removeClass("active");
                jQuery(this).addClass("active");
                var E = jQuery(this).attr("id");
                if (E == "current_background") {
                    settings.setBackgroundImage(_tmp.currentImage)
                } else {
                    if (E == "no_background") {
                        settings.setBackgroundImage("none")
                    }
                }
                return false
            });
            jQuery("#user_profile_background_tile").click(function() {
                var E = jQuery("#user_profile_background_tile:checked").val();
                jQuery("body").css({
                    "background-repeat": E ? "repeat": "no-repeat",
                    "background-attachment": E ? "scroll": "fixed"
                });
                jQuery("#user_profile_use_background_image").val("true")
            });
            settings.colorPicker = jQuery.farbtastic("#picker", settings.synchColors);
            jQuery("#picker").click(function() {
                jQuery(".colorwell-selected").focus()
            });
            var D;
            var C = (function() {
                var E = [8, 9, 13, 16, 17, 18, 37, 38, 39, 40, 45, 46, 86, 88, 90];
                for (var F = 48; F <= 57; F++) {
                    E.push(F)
                }
                for (var F = 65; F <= 70; F++) {
                    E.push(F)
                }
                for (var F = 96; F <= 105; F++) {
                    E.push(F)
                }
                return E
            })();
            jQuery(".colorwell").each(settings.synchColors).focus(function() {
                if (D) {
                    jQuery(D).removeClass("colorwell-selected")
                }
                settings.colorPicker.linked = this;
                settings.colorPicker.setColor(this.value);
                jQuery("#picker").show();
                jQuery(D = this).addClass("colorwell-selected")
            }).blur(function() {
                var E = jQuery(E);
                E.val(E.val().toUpperCase())
            }).keydown(function(E) {
                if (jQuery.inArray(E.keyCode, C) != -1) {
                    if (jQuery.inArray(E.keyCode, [86, 88, 90]) != -1) {
                        return (E.ctrlKey || E.metaKey)
                    } else {
                        if ((jQuery.inArray(E.keyCode, [8, 46]) != -1) || ((E.keyCode == 88) && E.shiftKey)) {
                            return (jQuery(this).val() != "#")
                        } else {
                            if (E.shiftKey) {
                                return (jQuery.inArray(E.keyCode, [65, 66, 67, 68, 69, 70]) != -1)
                            }
                        }
                    }
                    return true
                }
                return false
            }).keyup(function(E) {
                if (jQuery(this).val().indexOf("#") != 0) {
                    jQuery(this).val("#" + jQuery(this).val())
                }
                settings.colorPicker.setColor(this.value);
                var F = jQuery(this).val();
                if (!document.all || (F.length == 7 || F.length == 4)) {
                    jQuery(this).css({
                        "background-color": jQuery(this).val(),
                        color: settings.colorPicker.hsl[2] > 0.5 ? "#000000": "#ffffff"
                    });
                    settings.updateColors()
                }
            });
            jQuery("#design_customization form a").click(settings.updateColors)
        }
    };
    return A
} ();

jQuery(document).ready(function() {
		if($('settingsBox')) 
    	settings.initDesignSettings();
});
