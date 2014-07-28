require(["webjars!knockout.js", 'webjars!jquery.js', "/routes.js", "webjars!bootstrap.js"], (ko) ->


  # Models for the messages page
  class MessagesModel
    constructor: () ->
      self = @

      # valor actual del mensaje del mensaje de la predicciÃ³n mostrada en pantalla al usuario
      @prediccionActual = ko.observable("")

      # valor actual del ID de la predicción a modificar
      @idValue = ko.observable()

      # valores posibles para el campo Signo
      @signoValues = ["", "Aries", "Tauro", "Géminis", "Cancer", "Leo", "Virgo", "Libra", "Escorpio", "Sagitario", "Capricornio", "Acuario", "Piscis"]

      # valor actual del campo signo
      @selectedSignoValue = ko.observable("")

      # the list of messages
      @messages = ko.observableArray()

      # the messages field that messages are entered into
      @messageField = ko.observable()



      # devuelve el resumen de un texto pasado como parametro
      @resumen = (texto) ->
        if(texto.length > 200)
          texto.substring(0,199).concat("...")
        else
          texto


      # carga una predicción en base al signo seleccionado por el usuario
      @cargaPrediccion = () ->
        self.prediccionActual("")
        if(self.selectedSignoValue() != "")
          for message in self.messages()
            do(message) ->
              if(message.signo == self.selectedSignoValue())
                self.prediccionActual(message.message)


      # carga un Item para su edición o borrado en el formulario
      @cargaItem = (item) ->
        @messageItem = self.messages()[self.messages().indexOf(item)].message
        @signoItem = self.messages()[self.messages().indexOf(item)].signo
        @idItem = self.messages()[self.messages().indexOf(item)]._id
        #$("#geek").text("Message: " + @messageItem)
        self.messageField(@messageItem)
        self.selectedSignoValue(@signoItem)
        self.idValue(@idItem)
        #console.log(@idItem)

      # actualiza los campos de una predicción
      @updateMessage = () ->
        @ajax(routes.controllers.MessageController.updateMessage(), {
          data: JSON.stringify({
            _id: @idValue()
            message: @messageField()
            signo: @selectedSignoValue()
          })
          contentType: "application/json"
        }).done(() ->
          $("#updateMessageModal").modal("hide")
        )

      # borra una predicción
      @removeMessage = () ->
        @ajax(routes.controllers.MessageController.removeMessage(), {
          data: JSON.stringify({
            _id: @idValue()
            message: @messageField()
            signo: @selectedSignoValue()
          })
          contentType: "application/json"
        }).done(() ->
          $("#updateMessageModal").modal("hide")
        )

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
