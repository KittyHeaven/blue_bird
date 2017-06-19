defmodule BlueBird.Test.Support.Examples.Responses do
  @moduledoc false

  alias BlueBird.{ApiDoc, Request, Response, Route}

  def api_doc do
    %ApiDoc{
      title: "Lavish API",
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
                {"favorite-color", "greenish"},
                {"age-in-dog-years", "8"}
              ],
              body: "Multiple headers."
            }
          }]
        }
      ]
    }
  end

  def apib do
    """
    FORMAT: 1A
    HOST: https://youarguelikeaninformer.socrates

    # Lavish API


    ## /multiple-headers

    ### GET

    + Response 200 (text/plain)

        + Headers

                favorite-color: greenish
                age-in-dog-years: 8

        + Body

                Multiple headers.

    ## /plain-response

    ### GET

    + Response 200 (text/plain)

        + Body

                Plain response.

    ## /plain-with-line-breaks

    ### GET

    + Response 200 (text/plain)

        + Body

                I think that I shall never see
                A poem lovely as a tree

                A tree whose hungry mouth is prest
                Against the earth's sweet flowing breast
    """
  end

  def swagger, do: %{}
end
