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

let api_host = "https://apidojo-yahoo-finance-v1.p.rapidapi.com/stock/v2/get-options?symbol=CCL&date=1591920000"

let setup_log ?style_renderer level =
  Fmt_tty.setup_std_outputs ?style_renderer ();
  Logs.set_level level;
  Logs.set_reporter (Logs_fmt.reporter ());
  ()

let request host =
  let headers = [
      ("x-rapidapi-host", "apidojo-yahoo-finance-v1.p.rapidapi.com");
      ("x-rapidapi-key", "f017d34f2bmsh07c62cddedfaf64p115d31jsn1c964b4086f2");
  ]
  in
  let open Lwt_syntax.Result in
  let* response = Piaf.Client.Oneshot.get
    ~config:{ Piaf.Config.default with follow_redirects = true } (Uri.of_string host)
    ~headers in
  let (stream, _) = Piaf.Body.to_string_stream response.body in
  let open Lwt_syntax.Async in
  let+ () = 
    Lwt_stream.iter_s
      (fun chunk -> Lwt_io.printf "%s" chunk)
      stream
  in
  Ok ()

let () =
  setup_log (Some Logs.Debug);
  Lwt_main.run 
    (request api_host >|= function
     | Ok () ->
       ()
     | Error e ->
        failwith (Piaf.Error.to_string e))
  