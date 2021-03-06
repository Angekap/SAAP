(function(){
  var getForm = function(elem){
    return $(elem).closest('li').children('form.group-form');
  };

  var getDiv = function(elem){
    return $(elem).closest('li').children('div.group-div');
  };

  $('a.group-form-submit').on('click', function(e){
    $form = getForm(this);
    $link = getDiv(this);
    $.ajax({
      type: 'PATCH',
      dataType: 'JSON',
      url: $form.attr('action'),
      data: $form.serialize(),
      success: function(data){
        if(data == undefined){
          $form.hide();
          $link.show();
        }
        location.reload();
      }
    });
  });

  $('a.group-edit-link').on('click', function(){
    $link = getDiv(this);
    $form = getForm(this);
    $link.hide();
    $form.show();
    $('select', $form).chosen('destroy').chosen();
  });

  $('a.group-delete-link').on('click', function(){
    if (confirm($(this).data('confirm'))){
      $link = getDiv(this);
      $.ajax({
        type: 'DELETE',
        url: this.href
      }).success(function(data){
        $link.closest('li').remove();
        window.location.reload();
      });
    }
    return false;
  });
})();
