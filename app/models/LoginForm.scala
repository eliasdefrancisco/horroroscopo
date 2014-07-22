package models

import play.api.data._
import play.api.data.Forms._

/**
 * Created by Elias on 22/07/2014.
 *
 * Modelo de datos del formulario
 *
 */

case class LoginData(pass: String)

object LoginForm {
  val loginForm = Form(
    mapping(
      "Password" -> nonEmptyText
    )(LoginData.apply)(LoginData.unapply)
  )
}
