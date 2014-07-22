package controllers

import play.api.mvc._
import play.api.libs.json.Json
import play.api.libs.concurrent.Execution.Implicits._
import models._
import services.MessageDao
import reactivemongo.bson.BSONObjectID
import scala.concurrent.Future

object MessageController extends Controller {

  /** Action to get the messages */
  def getMessages() = Action.async { implicit req =>
    for {
      count <- MessageDao.count
      messages <- MessageDao.findAll()
    } yield {
      Ok(Json.toJson(messages))
    }
  }

  /**
   * The message form.  This is separate from the database message since the form doesn't have an ID.
   */
  case class MessageForm(message: String) {
    def toMessage: Message = Message(BSONObjectID.generate, message)
  }

  implicit val messageFormFormat = Json.format[MessageForm]

  /** Action to save a message */
  def saveMessage = Action.async(parse.json) { req =>
    Json.fromJson[MessageForm](req.body).fold(
      invalid => Future.successful(BadRequest("Bad message form")),
      form => MessageDao.save(form.toMessage).map(_ => Created)
    )
  }

}