submitSuccess = (data) ->
    name = data.name
    password = $('#password').val()

    $hiddenForm = $('#hidden-form')
    $('.name', $hiddenForm).val(name)
    $('.password', $hiddenForm).val(password)
    $('body').append($hiddenForm)
    $hiddenForm.submit()

submitError = (xhr, textStatus, error) ->
    if xhr.responseText
        alert(xhr.responseText)
    else
        alert("Something went wrong, please try again")
    

$ ->
    $('#form').submit ->
        audioURL = $('#audio-url').val()
        password = $('#password').val()
        $.ajax
            url: '/create'
            data:
                'audio-url': audioURL
                password: password
            type: 'POST'
            success: submitSuccess
            error: submitError
        return false

