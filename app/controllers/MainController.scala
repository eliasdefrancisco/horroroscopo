package controllers

import play.api.mvc._
import play.api.Routes
import services.EventDao
import play.api.libs.EventSource
import models._

object MainController extends Controller {

  /**
   * The index page.  This is the main entry point, seeing as this is a single page app.
   */
  def index(path: String) = Action {
    Ok(views.html.index())
  }

  /** The javascript router. */
  def router = Action { implicit req =>
    Ok(
      Routes.javascriptRouter("routes")(
        routes.javascript.MainController.events,
        routes.javascript.MessageController.getMessages,
        routes.javascript.MessageController.saveMessage,
        routes.javascript.MessageController.updateMessage,
        routes.javascript.MessageController.removeMessage
      )
    ).as("text/javascript")
  }

  /** Server Sent Events endpoint. */
  def events = Action {
    Ok.feed(EventDao.stream &> EventSource()).as(EVENT_STREAM)
  }

  /** Proceso de identificación del Admin */
  def login() = Action { implicit request =>
    import LoginForm._
    // Comprueba las variables del formulario pasadas mediante POST
    loginForm.bindFromRequest.fold(
      formWithErrors => {
        // binding failure, you retrieve the form containing errors:
        NotFound(views.html.login(loginForm))
      },
      loginData => {
        /* binding success, you get the actual value. */
        loginData.pass match {
          case "1234" => Redirect(routes.MainController.indexAdmin()).withSession("auth" -> "si")
          case _ => Unauthorized(views.html.login(LoginForm.loginForm))
        }
      }
    )
  }

  /** Comprueba si estamos identificados y nos lleva a la administración */
  def indexAdmin() = Action { implicit request =>
    //Ok(request.session.get("auth").toString())
    request.session.get("auth") match{
      case Some("si") => Ok(views.html.indexAdmin())
      case _ => Redirect(routes.MainController.login())
    }
  }

  /** Nos desloga del sistema*/
  def logout() = Action {
    Redirect(routes.MainController.index("")).withNewSession
  }

}
