class Application
  def call(env)
    router = Router.new(env)
    response = router.call

    response.finish
  end
end
