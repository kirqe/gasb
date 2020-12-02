module ServiceRegistry
  include ServiceAccounts
  @refs = []

  class << self
    attr_reader :refs

    def included(klass)
      @refs << klass
    end

    def select_service(term, client_email)
      kind, id = term.split(":").map(&:to_sym) 
      service_class = @refs.find {|r| r.ref == kind}

      service_account = ServiceAccounts.select_account(client_email)
      service = service_class.new(id, service_account)

      yield service if block_given?
      service
    end
  end
end
