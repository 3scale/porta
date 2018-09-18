jQuery.fn.farbtastic = function(A) {
    jQuery.farbtastic(this, A);
    return this
};
jQuery.farbtastic = function(A, B) {
    var A = jQuery(A).get(0);
    return A.farbtastic || (A.farbtastic = new jQuery._farbtastic(A, B))
};
jQuery._farbtastic = function(A, D) {
    var B = this;
    jQuery(A).html('<div class="farbtastic"><div class="color"></div><div class="wheel"></div><div class="overlay"></div><div class="h-marker marker"></div><div class="sl-marker marker"></div></div>');
    var C = jQuery(".farbtastic", A);
    B.wheel = jQuery(".wheel", A).get(0);
    B.radius = 84;
    B.square = 100;
    B.width = 194;
    if (navigator.appVersion.match(/MSIE [0-6]./)) {
        jQuery("*", C).each(function() {
            if (this.currentStyle.backgroundImage != "none") {
                var E = this.currentStyle.backgroundImage;
                E = this.currentStyle.backgroundImage.substring(5, E.length - 2);
                jQuery(this).css({
                    backgroundImage: "none",
                    filter: "progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=crop, src='" + E + "')"
                })
            }
        })
    }
    B.linkTo = function(E) {
        if (typeof B.callback == "object") {
            jQuery(B.callback).unbind("keyup", B.updateValue)
        }
        B.color = null;
        if (typeof E == "function") {
            B.callback = E
        } else {
            if (typeof E == "object" || typeof E == "string") {
                B.callback = jQuery(E);
                B.callback.bind("keyup", B.updateValue);
                if (B.callback.get(0).value) {
                    B.setColor(B.callback.get(0).value)
                }
            }
        }
        return this
    };
    B.updateValue = function(E) {
        if (this.value && this.value != B.color) {
            B.setColor(this.value)
        }
    };
    B.setColor = function(E) {
        var F = B.unpack(E);
        if (B.color != E && F) {
            B.color = E;
            B.rgb = F;
            B.hsl = B.RGBToHSL(B.rgb);
            B.updateDisplay()
        }
        return this
    };
    B.setHSL = function(E) {
        B.hsl = E;
        B.rgb = B.HSLToRGB(E);
        B.color = B.pack(B.rgb);
        B.updateDisplay();
        return this
    };
    B.widgetCoords = function(H) {
        var F,
        L;
        var G = H.target || H.srcElement;
        var E = B.wheel;
        if (typeof H.offsetX != "undefined") {
            var K = {
                x: H.offsetX,
                y: H.offsetY
            };
            var I = G;
            while (I) {
                I.mouseX = K.x;
                I.mouseY = K.y;
                K.x += I.offsetLeft;
                K.y += I.offsetTop;
                I = I.offsetParent
            }
            var I = E;
            var J = {
                x: 0,
                y: 0
            };
            while (I) {
                if (typeof I.mouseX != "undefined") {
                    F = I.mouseX - J.x;
                    L = I.mouseY - J.y;
                    break
                }
                J.x += I.offsetLeft;
                J.y += I.offsetTop;
                I = I.offsetParent
            }
            I = G;
            while (I) {
                I.mouseX = undefined;
                I.mouseY = undefined;
                I = I.offsetParent
            }
        } else {
            var K = B.absolutePosition(E);
            F = (H.pageX || 0 * (H.clientX + jQuery("html").get(0).scrollLeft)) - K.x;
            L = (H.pageY || 0 * (H.clientY + jQuery("html").get(0).scrollTop)) - K.y
        }
        return {
            x: F - B.width / 2,
            y: L - B.width / 2
        }
    };
    B.mousedown = function(E) {
        if (!document.dragging) {
            jQuery(document).bind("mousemove", B.mousemove).bind("mouseup", B.mouseup);
            document.dragging = true
        }
        var F = B.widgetCoords(E);
        B.circleDrag = Math.max(Math.abs(F.x), Math.abs(F.y)) * 2 > B.square;
        B.mousemove(E);
        return false
    };
    B.mousemove = function(H) {
        var I = B.widgetCoords(H);
        if (B.circleDrag) {
            var G = Math.atan2(I.x, -I.y) / 6.28;
            if (G < 0) {
                G += 1
            }
            B.setHSL([G, B.hsl[1], B.hsl[2]])
        } else {
            var F = Math.max(0, Math.min(1, -(I.x / B.square) + 0.5));
            var E = Math.max(0, Math.min(1, -(I.y / B.square) + 0.5));
            B.setHSL([B.hsl[0], F, E])
        }
        return false
    };
    B.mouseup = function() {
        jQuery(document).unbind("mousemove", B.mousemove);
        jQuery(document).unbind("mouseup", B.mouseup);
        document.dragging = false
    };
    B.updateDisplay = function() {
        var E = B.hsl[0] * 6.28;
        jQuery(".h-marker", C).css({
            left: Math.round(Math.sin(E) * B.radius + B.width / 2) + "px",
            top: Math.round( - Math.cos(E) * B.radius + B.width / 2) + "px"
        });
        jQuery(".sl-marker", C).css({
            left: Math.round(B.square * (0.5 - B.hsl[1]) + B.width / 2) + "px",
            top: Math.round(B.square * (0.5 - B.hsl[2]) + B.width / 2) + "px"
        });
        jQuery(".color", C).css("backgroundColor", B.pack(B.HSLToRGB([B.hsl[0], 1, 0.5])));
        if (typeof B.callback == "object") {
            jQuery(B.callback).css({
                backgroundColor: B.color,
                color: B.hsl[2] > 0.5 ? "#000": "#fff"
            });
            jQuery(B.callback).each(function() {
                if (this.value && this.value != B.color) {
                    this.value = B.color.toUpperCase()
                }
            })
        } else {
            if (typeof B.callback == "function") {
                B.callback.call(B, B.color)
            }
        }
    };
    B.absolutePosition = function(F) {
        var G = {
            x: F.offsetLeft,
            y: F.offsetTop
        };
        if (F.offsetParent) {
            var E = B.absolutePosition(F.offsetParent);
            G.x += E.x;
            G.y += E.y
        }
        return G
    };
    B.pack = function(F) {
        var H = Math.round(F[0] * 255);
        var G = Math.round(F[1] * 255);
        var E = Math.round(F[2] * 255);
        return "#" + (H < 16 ? "0": "") + H.toString(16) + (G < 16 ? "0": "") + G.toString(16) + (E < 16 ? "0": "") + E.toString(16)
    };
    B.unpack = function(E) {
        if (E.length == 7) {
            return [parseInt("0x" + E.substring(1, 3)) / 255, parseInt("0x" + E.substring(3, 5)) / 255, parseInt("0x" + E.substring(5, 7)) / 255]
        } else {
            if (E.length == 4) {
                return [parseInt("0x" + E.substring(1, 2)) / 15, parseInt("0x" + E.substring(2, 3)) / 15, parseInt("0x" + E.substring(3, 4)) / 15]
            }
        }
    };
    B.HSLToRGB = function(J) {
        var L,
        K,
        E,
        H,
        I;
        var G = J[0],
        M = J[1],
        F = J[2];
        K = (F <= 0.5) ? F * (M + 1) : F + M - F * M;
        L = F * 2 - K;
        return [this.hueToRGB(L, K, G + 0.33333), this.hueToRGB(L, K, G), this.hueToRGB(L, K, G - 0.33333)]
    };
    B.hueToRGB = function(F, E, G) {
        G = (G < 0) ? G + 1: ((G > 1) ? G - 1: G);
        if (G * 6 < 1) {
            return F + (E - F) * G * 6
        }
        if (G * 2 < 1) {
            return E
        }
        if (G * 3 < 2) {
            return F + (E - F) * (0.66666 - G) * 6
        }
        return F
    };
    B.RGBToHSL = function(J) {
        var G,
        L,
        M,
        H,
        N,
        F;
        var E = J[0],
        I = J[1],
        K = J[2];
        G = Math.min(E, Math.min(I, K));
        L = Math.max(E, Math.max(I, K));
        M = L - G;
        F = (G + L) / 2;
        N = 0;
        if (F > 0 && F < 1) {
            N = M / (F < 0.5 ? (2 * F) : (2 - 2 * F))
        }
        H = 0;
        if (M > 0) {
            if (L == E && L != I) {
                H += (I - K) / M
            }
            if (L == I && L != K) {
                H += (2 + (K - E) / M)
            }
            if (L == K && L != E) {
                H += (4 + (E - I) / M)
            }
            H /= 6
        }
        return [H, N, F]
    };
    jQuery("*", C).mousedown(B.mousedown);
    B.setColor("#000000");
    if (D) {
        B.linkTo(D)
    }
};
