
jQuery(document).ready(function(){
        jQuery('#prompt').keydown(function(event) {
                // if key pressed in input box, and in char mode, trigger submit.

                if(jQuery('#prompt_type').text() == 'char') {
                    jQuery('#keycode_input').val(event.which);
                    jQuery('#input').submit();
                }
                return true;
            });


        jQuery("#input").submit(function() {
                var fields = jQuery("#input").serialize();
                jQuery.ajax({ 
                        url: "/game/continue", 
                        data: fields,
                        success: function(data) {
                            jQuery.each(data.windows, function(ind, value) { 
                                    var win_div = jQuery("#"+value.winid);
                                    if(value.status == 'clear') {
                                        win_div.text('');
                                    }
                                    win_div.append(value.content);
                                    //  alert(win_div.height());
                                    
                                    var move_end = win_div.find('div.move-end').last();
                                    win_div.scrollTop(0);
                                    
                                    //alert('pos:' + move_end.position().top + 'offset: ' + move_end.offset().top + 'win off:' + win_div.offset().top);
                                    win_div.scrollTop(move_end.offset().top - win_div.offset().top);
                                });
                            jQuery('#prompt_type').text(data.input_type);
                            jQuery('#input_type').val(data.input_type);
                            jQuery('#prompt').val('');
                            jQuery('#keycode_input').val('');
                        },
                            dataType: 'json',
                        error: function(XMLHttpRequest, textStatus, errorThrown) {
                            alert(textStatus);
                        }
                    });
                return false;
            });
    });
