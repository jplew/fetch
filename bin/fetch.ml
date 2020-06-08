open Lwt.Infix
module Lwt_syntax = struct
  module Async = struct
    open Lwt

    let ( let+ ) x f = map f x

    let ( let* ) = bind
  end

  module Result = struct
    open Lwt_result

    let ( let+ ) x f = map f x

    let ( let* ) = bind
  end
end

let setup_log ?style_renderer level =
  Fmt_tty.setup_std_outputs ?style_renderer ();
  Logs.set_level level;
  Logs.set_reporter (Logs_fmt.reporter ());
  ()

let request host =
  let open Lwt_syntax.Result in
  let* response = Piaf.Client.Oneshot.get
    ~config:{ Piaf.Config.default with follow_redirects = true } (Uri.of_string host)
     in
  Piaf.Body.iter_string_s (fun chunk -> Lwt_io.printf "%s" chunk) response.body

let () =
  setup_log (Some Logs.Debug);
  Lwt_main.run 
    (request "https://github.com" >|= function
      | Ok () ->
        ()
      | Error e ->
        failwith (Piaf.Error.to_string e))
  