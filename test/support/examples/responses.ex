defmodule BlueBird.Test.Support.Examples.Responses do
  @moduledoc false

  alias BlueBird.{ApiDoc, Request, Response, Route}

  def api_doc do
    %ApiDoc{
      title: "Heavenly API",
      host: "https://youarguelikeaninformer.socrates",
      routes: [
        %Route{
          method: "GET",
          path: "/plain-response",
          requests: [%Request{
            method: "GET",
            path: "/plain-response",
            response: %Response{
              status: 200,
              headers: [{"content-type", "text/plain"}],
              body: "Plain response."
            }
          }]
        },
        %Route{
          method: "GET",
          path: "/plain-with-line-breaks",
          requests: [%Request{
            method: "GET",
            path: "/plain-with-line-breaks",
            response: %Response{
              status: 200,
              headers: [{"content-type", "text/plain"}],
              body: "I think that I shall never see\n" <>
                    "A poem lovely as a tree\n\n" <>
                    "A tree whose hungry mouth is prest\n" <>
                    "Against the earth's sweet flowing breast"
            }
          }]
        },
        %Route{
          method: "GET",
          path: "/multiple-headers",
          requests: [%Request{
            method: "GET",
            path: "/multiple-headers",
            response: %Response{
              status: 200,
              headers: [
                {"content-type", "text/plain"},
                {"favorite-color", "greenish"}
              ],
              body: "Multiple headers."
            }
          }]
        },
      ]
    }
  end

  def output do
    """
    FORMAT: 1A
    HOST: https://youarguelikeaninformer.socrates

    # Heavenly API


    ## /multiple-headers

    ### GET

        + Request

        + Response 200

            + Headers

                content-type: text/plain
                favorite-color: greenish

            + Body

                Multiple headers.

    ## /plain-response

    ### GET

        + Request

        + Response 200

            + Headers

                content-type: text/plain

            + Body

                Plain response.

    ## /plain-with-line-breaks

    ### GET

        + Request

        + Response 200

            + Headers

                content-type: text/plain

            + Body

                I think that I shall never see
                A poem lovely as a tree

                A tree whose hungry mouth is prest
                Against the earth's sweet flowing breast
    """
  end
end
