open Lwt.Infix

let setup_log ?style_renderer level =
  Fmt_tty.setup_std_outputs ?style_renderer ();
  Logs.set_level level;
  Logs.set_reporter (Logs_fmt.reporter ());
  ()

let request host =
  Piaf.Client.Oneshot.get
    ~config:{ Piaf.Config.default with follow_redirects = true }
    (Uri.of_string host)
  >|= function
  | Ok _response ->
    ()
  | Error e ->
    failwith e

let () =
  setup_log (Some Logs.Debug);
  let host = "https://www.github.com" in
  Lwt_main.run (request host)
