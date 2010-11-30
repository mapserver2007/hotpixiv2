require 'thread'

module HotPixiv
  module Runner
    def self.parallel(list, concurency = 10, qsize = nil)
      q = qsize ? SizedQueue.new(qsize) : Queue.new
      # Producerを作成
      threads = []
      producer = Thread.start(q, concurency) do |pq, pc|
        list.each do |url|
          pq.enq([url, true])
        end
        pc.times{pq.enq([nil, false])}
      end
      # Consumerを作成
      workers = []
      concurency.times do
        workers << Thread.start(q) do |wq|
          url, flg = wq.deq
          while flg
            yield url
            url, flg = wq.deq
          end
        end
      end
      producer.join
      workers.each{|w| w.join}
    end
  end
end