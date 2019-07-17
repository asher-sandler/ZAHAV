function showModal(id,fam,phone,address,house,flat,siteroot) {

    var num = phone.substr(0,3)+"-"+phone.substr(3,3);



    html = '<form class="form-horizontal notice-success"   role="form" action="/'+siteroot+'pbk/ask_for_delete" method="post">';

    html+=    '<div class="form-group">'+
        '<label  class="col-sm-2 control-label" for="FAMILY-form-id-001">Фамилия:</label>'+
        '<div class="col-sm-10">'+
        '<label type="text" class="form-control" id="FAMILY-form-id-001" name="FAMILY-form-id-001"   >'+fam+'<label/>'+
        '</div>' +
        '</div>';


    html+=    '<div class="form-group">'+
        '<label  class="col-sm-2 control-label" for="PHONE-form-id-001">Телефон:</label>'+
        '<div class="col-sm-10">'+
        '<label type="text" class="form-control" id="PHONE-form-id-001"  name="PHONE-form-id-001"  >'+phone+'<label/>'+
        '</div>' +
        '</div>';


    html+=    '<div class="form-group">'+
        '<label  class="col-sm-2 control-label" for="ADDRESS-form-id-001">Адрес:</label>'+
        '<div class="col-sm-10">'+
        '<label type="text" class="form-control" id="ADDRESS-form-id-001" name="ADDRESS-form-id-001" >'+address+'<label/>'+
        '</div>' +
        '</div>';

    html+=    '<div class="form-group">'+
        '<label  class="col-sm-2 control-label" for="HOUSE-form-id-001">Дом:</label>'+
        '<div class="col-sm-10">'+
        '<label type="text" class="form-control" id="HOUSE-form-id-001" name="HOUSE-form-id-001" >'+house+'<label/>'+
        '</div>' +
        '</div>';


    html+=    '<div class="form-group">'+
        '<label  class="col-sm-2 control-label" for="FLAT-form-id-001">Кв.:</label>'+
        '<div class="col-sm-10">'+
        '<label type="text" class="form-control" id="FLAT-form-id-001" name="FLAT-form-id-001" >'+flat+'<label/>'+
        '</div>' +
        '</div>';


    html+= '<input type="hidden"  id="hidden-form-id-0001" name="hidden-form-id-0001" value="'+id+'"/>';


    editModtxt ='onclick="editModal('+
        "'"+id+"',"+
        "'"+fam+"',"+
        "'"+phone+"',"+
        "'"+address+"',"+
        "'"+house+"',"+
        "'"+flat+"',"+
        "'"+siteroot+"'"+')"';

    //alert(editModtxt);

    html+=    '</div><div class="form-group">'+
        '<div class="col-sm-offset-2 col-sm-10">'+
        '<button  class="btn btn-info" '+
         editModtxt+
        ' ><span class="glyphicon glyphicon-pencil"'+
        '"></span>Редактировать</button>'+
        '<button type="submit" class="btn btn-danger"><span class="glyphicon glyphicon-trash"></span>Удалить</button>'+
        '</div><div>'+
        '</form>';


    //alert(html);
    //obj=JSON.parse(data);
    $("#myModal .modal-header").html("Просмотр: <b>"+fam+"</b>")
    $("#myModal .modal-title").html("Телефон: <b>"+num+"</b>")
    $("#myModal .modal-body").html(html)
    $("myModal").modal();
}
function editModal(id,fam,phone,address,house,flat,siteroot) {

    var num = phone.substr(0,3)+"-"+phone.substr(3,3);



    html = '<form class="form-horizontal" role="form" action="/'+siteroot+'pbk" method="post">';

    html+=    '<div class="form-group">'+
        '<label  class="col-sm-2 control-label" for="FAMILY-form-id-001">Фамилия:</label>'+
        '<div class="col-sm-10">'+
        '<input type="text" class="form-control" id="FAMILY-form-id-001" name="FAMILY-form-id-001"  placeholder="Фамилия" value="'+fam+'"/>'+
        '</div>' +
        '</div>';


    html+=    '<div class="form-group">'+
        '<label  class="col-sm-2 control-label" for="PHONE-form-id-001">Телефон:</label>'+
        '<div class="col-sm-10">'+
        '<input type="text" class="form-control" id="PHONE-form-id-001"  name="PHONE-form-id-001"  placeholder="Телефон" value="'+phone+'"/>'+
        '</div>' +
        '</div>';


    html+=    '<div class="form-group">'+
        '<label  class="col-sm-2 control-label" for="ADDRESS-form-id-001">Адрес:</label>'+
        '<div class="col-sm-10">'+
        '<input type="text" class="form-control" id="ADDRESS-form-id-001" name="ADDRESS-form-id-001" placeholder="Адрес" value="'+address+'"/>'+
        '</div>' +
        '</div>';

    html+=    '<div class="form-group">'+
        '<label  class="col-sm-2 control-label" for="HOUSE-form-id-001">Дом:</label>'+
        '<div class="col-sm-10">'+
        '<input type="text" class="form-control" id="HOUSE-form-id-001" name="HOUSE-form-id-001" placeholder="Дом" value="'+house+'"/>'+
        '</div>' +
        '</div>';


    html+=    '<div class="form-group">'+
        '<label  class="col-sm-2 control-label" for="FLAT-form-id-001">Кв.:</label>'+
        '<div class="col-sm-10">'+
        '<input type="text" class="form-control" id="FLAT-form-id-001" name="FLAT-form-id-001" placeholder="Кв." value="'+flat+'"/>'+
        '</div>' +
        '</div>';


    html+= '<input type="hidden"  id="hidden-form-id-0001" name="hidden-form-id-0001" value="'+id+'"/>';


    html+=    '</div><div class="form-group">'+
        '<div class="col-sm-offset-2 col-sm-10">'+
        '<button type="submit" class="btn btn-default">Сохранить</button>'+
        '</div><div>'+
        '</form>';


    //alert(html);
    //obj=JSON.parse(data);
    $("#myModal .modal-header").html("Редактирование: <b>"+fam+"</b>")
    $("#myModal .modal-title").html("Телефон: <b>"+num+"</b>")
    $("#myModal .modal-body").html(html)
    $("myModal").modal();
}
function AddModal(siteroot) {

    html = '<form class="form-horizontal" role="form" action="/'+siteroot+'pbk" method="post">';

    html+=    '<div class="form-group">'+
        '<label  class="col-sm-2 control-label" for="FAMILY-form-id-001">Фамилия:</label>'+
        '<div class="col-sm-10">'+
        '<input type="text" class="form-control" id="FAMILY-form-id-001" name="FAMILY-form-id-001"  placeholder="Фамилия" value=""/>'+
        '</div>' +
        '</div>';


    html+=    '<div class="form-group">'+
        '<label  class="col-sm-2 control-label" for="PHONE-form-id-001">Телефон:</label>'+
        '<div class="col-sm-10">'+
        '<input type="text" class="form-control" id="PHONE-form-id-001"  name="PHONE-form-id-001"  placeholder="Телефон" value=""/>'+
        '</div>' +
        '</div>';


    html+=    '<div class="form-group">'+
        '<label  class="col-sm-2 control-label" for="ADDRESS-form-id-001">Адрес:</label>'+
        '<div class="col-sm-10">'+
        '<input type="text" class="form-control" id="ADDRESS-form-id-001" name="ADDRESS-form-id-001" placeholder="Адрес" value=""/>'+
        '</div>' +
        '</div>';

    html+=    '<div class="form-group">'+
        '<label  class="col-sm-2 control-label" for="HOUSE-form-id-001">Дом:</label>'+
        '<div class="col-sm-10">'+
        '<input type="text" class="form-control" id="HOUSE-form-id-001" name="HOUSE-form-id-001" placeholder="Дом" value=""/>'+
        '</div>' +
        '</div>';


    html+=    '<div class="form-group">'+
        '<label  class="col-sm-2 control-label" for="FLAT-form-id-001">Кв.:</label>'+
        '<div class="col-sm-10">'+
        '<input type="text" class="form-control" id="FLAT-form-id-001" name="FLAT-form-id-001" placeholder="Кв." value=""/>'+
        '</div>' +
        '</div>';


    html+= '<input type="hidden"  id="hidden-form-id-0001" name="hidden-form-id-0001" value="-1"/>';


    html+=    '</div><div class="form-group">'+
        '<div class="col-sm-offset-2 col-sm-10">'+
        '<button type="submit" class="btn btn-default">Сохранить</button>'+
        '</div><div>'+
        '</form>';


    //alert(html);
    //obj=JSON.parse(data);
    $("#myModal .modal-header").html("Добавление:")
    $("#myModal .modal-title").html("Телефон: <b>НОВЫЙ</b>")
    $("#myModal .modal-body").html(html)
    $("myModal").modal();
}
