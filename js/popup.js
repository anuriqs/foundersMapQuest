// Generated by CoffeeScript 1.10.0
(function() {
  var Popup,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.Popup = Popup = (function() {
    function Popup(userDetailsSection, userDetailsGetInput) {
      this.closePopup = bind(this.closePopup, this);
      $("#openUserScreen").click(function(e) {
        var popup;
        popup = $(".Popup");
        popup.find(".TransparentBg").fadeIn(200, function() {
          return {
            complete: popup.find(".Popup_container").addClass("Show").removeClass("jsRemoveShow")
          };
        });
        $(userDetailsSection).removeClass("active");
        $(userDetailsGetInput).addClass("active");
        return Utils.disableScroll();
      });
      $(".PanelCloseBtn").click((function(_this) {
        return function() {
          return _this.closePopup();
        };
      })(this));
      $(document).on("keydown", (function(_this) {
        return function(e) {
          if (e.keyCode === 27) {
            return _this.closePopup();
          }
        };
      })(this));
      this.setPopupDimensions();
      $(window).on("resize", (function(_this) {
        return function() {
          return _this.setPopupDimensions();
        };
      })(this));
      $(document).click((function(_this) {
        return function(e) {
          var el;
          if ($(".Popup").find(".Popup_container").hasClass("Show")) {
            el = $(e.target);
            if (!(el.hasClass("Popup_container") || el.parents(".Popup_container").length || el.hasClass("ShowPopup"))) {
              return _this.closePopup();
            }
          }
        };
      })(this));
    }

    Popup.prototype.setPopupDimensions = function() {
      var screenHeight, screenWidth;
      screenHeight = $(window).height();
      screenWidth = $(window).width();
      if ($(window).width < 600) {
        return $(".Popup_content").css("max-height", screenHeight - 140);
      } else {
        return $(".Popup_content").css("max-height", screenHeight - 160);
      }
    };

    Popup.prototype.closePopup = function() {
      $(".Popup").find(".TransparentBg").fadeOut(200, function() {
        return {
          complete: $(".Popup").find(".Popup_container").removeClass("Show").addClass("jsRemoveShow")
        };
      });
      return Utils.enableScroll();
    };

    return Popup;

  })();

}).call(this);