package services

import play.modules.reactivemongo.ReactiveMongoPlugin
import play.modules.reactivemongo.json.collection.JSONCollection
import play.modules.reactivemongo.json.BSONFormats._
import play.api.Play.current
import models._
import models.Message._
import scala.concurrent.Future
import play.api.libs.concurrent.Execution.Implicits._
import play.api.libs.json.Json
import reactivemongo.api.QueryOpts
import reactivemongo.core.commands.Count
import reactivemongo.bson.BSONObjectID
import reactivemongo.bson.BSONDocument

/** A data access object for messages backed by a MongoDB collection */
object MessageDao {

  /** The messages collection */
  private def collection = ReactiveMongoPlugin.db.collection[JSONCollection]("predictions")

  /**
   * Save a message.
   *
   * @return The saved message, once saved.
   */
  def save(message: Message): Future[Message] =
    removeSigno(message).map{ m =>
      saveAfterRemove(m)
      m
    }

  /**
   * Elimina el signo pasado como parametro a toda la colección
   *
   */
  def removeSigno(message: Message): Future[Message] = {
    val selector = BSONDocument{"signo" -> message.signo}
    val modifier = BSONDocument{"$set" -> BSONDocument{"signo" -> ""}}
    collection.update(selector, modifier).map{
      case ok if ok.ok => message
      case error => throw new RuntimeException(error.message)
    }
  }

  /**
   * Guarda una predicción despues de removeSigno
   *
   */
  def saveAfterRemove(message: Message): Future[Message] = collection.save(message).map {
    case ok if ok.ok =>
      EventDao.publish("message", message)
      message
    case error => throw new RuntimeException(error.message)
  }

  /**
   * Elimina un mensaje de la colección
   *
   */
  def remove(message: Message): Future[Message] =
    collection.remove(message).map {
      case ok if ok.ok =>
        EventDao.publish("message", message)
        message
    }

  /**
   * Find all the messages.
   *
   * @return All of the messages.
   */
  def findAll(): Future[Seq[Message]] = {
    collection.find(Json.obj())
      .options(QueryOpts())
      .sort(Json.obj("_id" -> -1))
      .cursor[Message]
      .collect[Seq]()
  }

  /** The total number of messages */
  def count: Future[Int] = {
    ReactiveMongoPlugin.db.command(Count(collection.name))
  }

}
