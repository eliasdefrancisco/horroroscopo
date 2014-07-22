require(["webjars!knockout.js", 'webjars!jquery.js', "/routes.js", "webjars!bootstrap.js"], (ko) ->


  # Models for the messages page
  class MessagesModel
    constructor: () ->
      self = @
      # the list of messages
      @messages = ko.observableArray()

      # the messages field that messages are entered into
      @messageField = ko.observable()


      # save a new message
      @saveMessage = () ->
        @ajax(routes.controllers.MessageController.saveMessage(), {
          data: JSON.stringify({
            message: @messageField()
          })
          contentType: "application/json"
        }).done(() ->
          $("#addMessageModal").modal("hide")
          self.messageField(null)
        )

      # get the messages
      @getMessages = () ->
        @ajax(routes.controllers.MessageController.getMessages(0, messagesPerPage))
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

  # Server Sent Events handling
  events = new EventSource(routes.controllers.MainController.events().url)
  events.addEventListener("message", (e) ->
    model.getMessages()
  , false)
)
