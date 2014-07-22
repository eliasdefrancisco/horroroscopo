require(["webjars!knockout.js", 'webjars!jquery.js', "/routes.js", "webjars!bootstrap.js"], (ko) ->


  # Models for the messages page
  class MessagesModel
    constructor: () ->
      self = @

      # valores posibles para el campo Signo
      @signoValues = ["", "Aries", "Tauro", "Géminis", "Cancer", "Leo", "Virgo", "Libra", "Escorpio", "Sagitario", "Capricornio", "Acuario", "Piscis"]

      # valor actual del campo signo
      @selectedSignoValue = ko.observable("")

      # the list of messages
      @messages = ko.observableArray()

      # the messages field that messages are entered into
      @messageField = ko.observable()


      # establece a null todas las variables observables cuando se cierra la ventana del formulario
      @closeMessage = ->
        self.messageField(null)
        self.selectedSignoValue(null)
        self.idValue(null)

      # save a new message
      @saveMessage = () ->
        @ajax(routes.controllers.MessageController.saveMessage(), {
          data: JSON.stringify({
            message: @messageField()
            signo: @selectedSignoValue()
          })
          contentType: "application/json"
        }).done(() ->
          $("#addMessageModal").modal("hide")
        )

      # get the messages
      @getMessages = () ->
        @ajax(routes.controllers.MessageController.getMessages())
          .done((data, status, xhr) ->
            self.loadMessages(data, status, xhr)
          )


    # Convenience ajax request function
    ajax: (route, params) ->
      $.ajax($.extend(params, route))

    # Handle the messages response
    loadMessages: (data, status, xhr) ->
      @messages(data)


  # Setup
  model = new MessagesModel
  ko.applyBindings(model)

  # Load messages data
  model.getMessages()

  # Server Sent Events handling. Cuando llega un Evento tipo "message", se recarga la lista de mensajes completa
  events = new EventSource(routes.controllers.MainController.events().url)
  events.addEventListener("message", (e) ->
    model.getMessages()
  , false)
)
