module Magicbox::Checks
  class Compile < Magicbox::Check
    def parse
      begin
        code      = Magicbox::Webserver.sanitize(@data['code'])
        item      = Magicbox::Webserver.sanitize(@data['item'])
        t         = Magicbox::SpecTests::Share.new('compile', {})
        spec_test = t.make_spec
        sandbox   = Magicbox::SpecTests::Sandbox.new(
          item,
          'class',
          code,
          spec_test
        )

        # Run and clean
        exitstatus, cmd_out = sandbox.run!
        sandbox.cleanup!
      rescue RuntimeError => e
        { 'exitcode' => 1, 'message' => [e.message] }
      else
        json    = JSON.parse(cmd_out)
        message = if exitstatus.zero?
                    json.dig('examples', 0, 'status')
                  else
                    json.dig('examples', 0, 'exception', 'message')
                  end
        { 'exitcode' => exitstatus, 'message' => [message] }
      end
    end
  end
end
