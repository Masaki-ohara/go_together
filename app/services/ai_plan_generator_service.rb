# class AiPlanGeneratorService
#   def initialize(location:, budget:, theme:, item_count:)
#     @location = location
#     @budget = budget
#     @theme = theme
#     @item_count = item_count.to_i
#   end

#   def call
#     api_key = ENV["GEMINI_API_KEY"]
#     raise "GEMINI_API_KEY が設定されていません" if api_key.blank?

#     url = URI.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=#{api_key}")

#     client = Gemini.new(
#       service: "generative-language",
#       credentials: {
#         api_key: api_key
#       },
#       options: { model: "gemini-1.5-flash" }
#     )
#     # client = Gemini.new(
#     #   credentials: {
#     #     address: "https://generativelanguage.googleapis.com",
#     #     service_version: "v1beta",
#     #     api_key: ENV["GEMINI_API_KEY"]
#     #   },
#     #   options: { model: "gemini-1.5-flash" }
#     # )

#     prompt = <<~PROMPT
#       あなたは旅行・デートのプロフェッショナルなプランナーです。
#       以下の条件に合わせて、充実した1日の遊びプランを作成してください。

#       【条件】
#       - 場所: #{@location}
#       - 予算: #{@budget}円程度
#       - テーマ・雰囲気: #{@theme}

#       【出力フォーマット制限】
#       以下のJSON形式のみを出力してください。余計な挨拶やMarkdownのバックティックス（```jsonなど）は含めないでください。

#       {
#         "title": "プランのタイトル",
#         "location": "具体的な主要エリア",
#         "budget": 予算（数値のみ）,
#         "items": [
#           {
#             "start_time": "10:00",
#             "end_time": "11:30",
#             "content": "具体的な活動内容",
#             "category": "morning"
#           }
#         ]
#       }
#     PROMPT

#     response = client.generate_content({
#       contents: [{ role: "user", parts: [{ text: prompt }] }]
#     })

#     raw_text = response.dig("candidates", 0, "content", "parts", 0, "text")
#     clean_json_text = raw_text.gsub(/```json|```/, "").strip
    
#     JSON.parse(clean_json_text, symbolize_names: true)
#   rescue => e
#     Rails.logger.error("Gemini API Error: #{e.message}")
#     raise "AIプランの生成に失敗しました"
#   end
# end

# require "net/http"
# require "uri"
# require "json"

# class AiPlanGeneratorService
#   def initialize(location:, budget:, theme:, item_count: 3)
#     @location = location
#     @budget = budget
#     @theme = theme
#     @item_count = item_count.to_i
#   end

#   def call
#     api_key = ENV["GEMINI_API_KEY"]
#     raise "GEMINI_API_KEY が設定されていません" if api_key.blank?

#     # 最新の推奨モデル gemini-3.8-flash を指定
#     url = URI.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent?key=#{api_key}")

#     prompt = <<~PROMPT
#       あなたは旅行・デートのプロフェッショナルなプランナーです。
#       以下の条件に合わせて、1日の遊びプランを作成してください。

#       【条件】
#       - 場所: #{@location}
#       - 予算: #{@budget}円程度
#       - テーマ・雰囲気: #{@theme}
#       - 提案するスポット・活動の件数: #{@item_count}件

#       【出力フォーマット制限】
#       以下のJSON形式のみを出力してください。
#       解説、前置き、後置き、Markdownのコードブロック（```json ... ```）などは一切含めず、純粋なJSON文字列のみを返してください。
#       items 配列の中身はちょうど #{@item_count} 件にしてください。

#       {
#         "title": "プランのタイトル",
#         "location": "具体的な主要エリア",
#         "budget": #{@budget.presence || 0},
#         "items": [
#           {
#             "start_time": "10:00",
#             "end_time": "11:30",
#             "content": "具体的な活動内容",
#             "category": "morning"
#           }
#         ]
#       }
#     PROMPT

#     body = {
#       contents: [
#         {
#           parts: [
#             { text: prompt }
#           ]
#         }
#       ]
#     }

#     http = Net::HTTP.new(url.host, url.port)
#     http.use_ssl = true

#     request = Net::HTTP::Post.new(url.request_uri, { "Content-Type" => "application/json" })
#     request.body = body.to_json

#     response = http.request(request)

#     unless response.is_a?(Net::HTTPSuccess)
#       raise "Gemini API Error (HTTP #{response.code}): #{response.body}"
#     end

#     response_data = JSON.parse(response.body)
#     raw_text = response_data.dig("candidates", 0, "content", "parts", 0, "text")
#     raise "Geminiからのレスポンスが空です" if raw_text.blank?

#     clean_json_text = raw_text.gsub(/```(?:json)?/, "").strip
#     JSON.parse(clean_json_text, symbolize_names: true)

#   rescue JSON::ParserError => e
#     Rails.logger.error("Gemini JSON Parse Error: #{e.message}")
#     Rails.logger.error("Raw text received: #{raw_text}")
#     raise "AIが生成したデータのフォーマットが不正でした"
#   rescue => e
#     Rails.logger.error("Gemini API Error Detail: #{e.class} - #{e.message}")
#     Rails.logger.error(e.backtrace.first(10).join("\n"))
#     raise "AIプランの生成に失敗しました: #{e.message}"
#   end
# end

# require "net/http"
# require "uri"
# require "json"

# class AiPlanGeneratorService
#   # リトライ上限回数と基準遅延時間（秒）
#   MAX_RETRIES = 3
#   RETRY_DELAY = 2

#   # API過負荷・エラー発生時にフォールバック利用するモデルの一覧（優先度順）
# MODELS = [
#     "gemini-3.8-flash",
#     "gemini-3.7-flash",
#     "gemini-3.5-flash"
#   ].freeze

#   def initialize(location:, budget:, theme:, item_count: 3)
#     @location = location
#     @budget = budget
#     @theme = theme
#     @item_count = item_count.to_i
#   end

#   def call
#     # 1. 環境変数のチェック
#     api_key = ENV["GEMINI_API_KEY"]
#     raise "GEMINI_API_KEY が設定されていません" if api_key.blank?

#     # 2. Gemini APIへのプロンプト設定
#     # ヒアドキュメント内の変数は改行せずインラインで記述
#     prompt = <<~PROMPT
#       あなたは旅行・デートのプロフェッショナルなプランナーです。
#       以下の条件に合わせて、1日の遊びプランを作成してください。

#       【条件】
#       - 場所: #{@location}
#       - 予算: #{@budget}円程度
#       - テーマ・雰囲気: #{@theme}
#       - 提案するスポット・活動の件数: #{@item_count}件

#       【出力フォーマット制限】
#       以下のJSON形式のみを出力してください。
#       解説、前置き、後置き、Markdownのコードブロック（```json ... ```）などは一切含めず、純粋なJSON文字列のみを返してください。
#       items 配列の中身はちょうど #{@item_count} 件にしてください。

#       【時間の指定ルール (time)】
#       各アイテムの time には、以下のいずれかの文字列を**必ず正確に**設定してください。
#       選択肢: ["early morning", "morning", "lunch", "afternoon", "evening", "night"]

#       {
#         "title": "プランのタイトル",
#         "location": "具体的な主要エリア",
#         "budget": #{@budget.presence || 0},
#         "items": [
#           {
#             "start_time": "10:00",
#             "end_time": "11:30",
#             "content": "具体的な活動内容"
#           }
#         ]
#       }
#     PROMPT

#     # 3. Gemini APIのリクエストボディ作成
#     body = {
#       contents: [
#         {
#           parts: [
#             { text: prompt }
#           ]
#         }
#       ]
#     }

#     # リトライ回数およびモデル指定インデックスの初期化
#     retries = 0
#     model_index = 0

#     begin
#       # 現在試行するモデルの選定とURL生成
#       current_model = MODELS[model_index] || MODELS.last
#       url = URI.parse("https://generativelanguage.googleapis.com/v1beta/models/#{current_model}:generateContent?key=#{api_key}")

#       # 4. HTTPクライアントの設定とリクエスト送信
#       http = Net::HTTP.new(url.host, url.port)
#       http.use_ssl = true

#       request = Net::HTTP::Post.new(url.request_uri, { "Content-Type" => "application/json" })
#       request.body = body.to_json

#       response = http.request(request)

#       # 5. ステータスコードに応じたエラー判定
#       # 503 (Service Unavailable) や 429 (Too Many Requests) は一時的エラーとして例外を発生させ、rescue節へ飛ばす
#       if [503, 429].include?(response.code.to_i)
#         raise "Gemini API Temporary Error (HTTP #{response.code})"
#       end

#       # その他の200系以外のレスポンスをハンドリング
#       unless response.is_a?(Net::HTTPSuccess)
#         raise "Gemini API Error (HTTP #{response.code}): #{response.body}"
#       end

#       # 6. レスポンスのパース処理
#       response_data = JSON.parse(response.body)
#       raw_text = response_data.dig("candidates", 0, "content", "parts", 0, "text")
#       raise "Geminiからのレスポンスが空です" if raw_text.blank?

#       # 余分なMarkdown記法（```json ... ```）が混ざっていた場合のクリーニング処理
#       clean_json_text = raw_text.gsub(/```(?:json)?/, "").strip
#       JSON.parse(clean_json_text, symbolize_names: true)

#     rescue => e
#       # 7. 一時的な通信・負荷エラー発生時の自動リトライ＆フォールバック処理
#       if retries < MAX_RETRIES && e.message.include?("Temporary Error")
#         retries += 1
#         # 次のリトライでは配列の次のモデル（フォールバックモデル）を使用する
#         model_index = [model_index + 1, MODELS.size - 1].min
        
#         Rails.logger.warn("Gemini API Retry (#{retries}/#{MAX_RETRIES}) using #{MODELS[model_index]}: #{e.message}")
#         # リトライ間隔を空けて再実行（1回目: 2秒, 2回目: 4秒...）
#         sleep RETRY_DELAY * retries
#         retry # beginブロックの先頭から再実行
#       end

#       # 8. リトライ上限超過、または回復不可能なエラー時のログ出力と例外再送出
#       Rails.logger.error("Gemini API Error Detail: #{e.class} - #{e.message}")
#       Rails.logger.error(e.backtrace.first(10).join("\n"))
#       raise "AIプランの生成に失敗しました: #{e.message}"
#     end
#   end
# end

require "net/http"
require "uri"
require "json"

class AiPlanGeneratorService
  MAX_RETRIES = 3
  RETRY_DELAY = 2

  # 実在するGeminiモデルのみを指定
 # v1beta で確実に通るモデル識別子を指定
MODELS = [
  "gemini-3.7-flash"
  ].freeze

  def initialize(location:, budget:, theme:, item_count: 3)
    @location = location
    @budget = budget
    @theme = theme
    @item_count = item_count.to_i
  end

  def call
    api_key = ENV["GEMINI_API_KEY"]
    raise "GEMINI_API_KEY が設定されていません" if api_key.blank?

    prompt = <<~PROMPT
      あなたは旅行・デートのプロフェッショナルなプランナーです。
      以下の条件に合わせて、1日の遊びプランを作成してください。

      【条件】
      - 場所: #{@location}
      - 予算: #{@budget}円程度
      - テーマ・雰囲気: #{@theme}
      - 提案するスポット・活動の件数: #{@item_count}件

      【出力フォーマット制限】
      以下のJSON形式で返してください。items 配列の中身はちょうど #{@item_count} 件にしてください。

      【時間の指定ルール (time)】
      各アイテムの time には、以下のいずれかの文字列を必ず正確に設定してください。
      選択肢: ["early morning", "morning", "lunch", "afternoon", "evening", "night"]

      {
        "title": "プランのタイトル",
        "location": "具体的な主要エリア",
        "budget": #{@budget.presence || 0},
        "items": [
          {
            "time": "lunch",
            "start_time": "10:00",
            "end_time": "11:30",
            "content": "具体的な活動内容"
          }
        ]
      }
    PROMPT

    # 🔽 generationConfig で response_mime_type を指定（JSON途切れを防止）
    body = {
      contents: [
        {
          parts: [{ text: prompt }]
        }
      ],
      generationConfig: {
        response_mime_type: "application/json"
      }
    }

    retries = 0
    model_index = 0

    begin
      current_model = MODELS[model_index] || MODELS.last
      model_path = current_model.start_with?("models/") ? current_model : "models/#{current_model}"
      url = URI.parse("https://generativelanguage.googleapis.com/v1beta/#{model_path}:generateContent?key=#{api_key}")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.read_timeout = 120
      http.open_timeout = 10

      request = Net::HTTP::Post.new(url.request_uri, { "Content-Type" => "application/json" })
      request.body = body.to_json

      response = http.request(request)

      if [503, 429].include?(response.code.to_i)
        raise "Gemini API Temporary Error (HTTP #{response.code})"
      end

      unless response.is_a?(Net::HTTPSuccess)
        raise "Gemini API Error (HTTP #{response.code}): #{response.body}"
      end

      response_data = JSON.parse(response.body)
      raw_text = response_data.dig("candidates", 0, "content", "parts", 0, "text")
      raise "Geminiからのレスポンスが空です" if raw_text.blank?

      clean_json_text = raw_text.gsub(/```(?:json)?/, "").strip
      JSON.parse(clean_json_text, symbolize_names: true)

    rescue Net::ReadTimeout, Net::OpenTimeout => e
      if retries < MAX_RETRIES
        retries += 1
        model_index = [model_index + 1, MODELS.size - 1].min
        Rails.logger.warn("Gemini API Timeout Retry (#{retries}/#{MAX_RETRIES}) using #{MODELS[model_index]}: #{e.message}")
        sleep RETRY_DELAY * retries
        retry
      end
      raise "Gemini APIとの通信がタイムアウトしました"

    rescue => e
      if retries < MAX_RETRIES && (e.message.include?("Temporary Error") || e.is_a?(JSON::ParserError))
        retries += 1
        model_index = [model_index + 1, MODELS.size - 1].min
        
        Rails.logger.warn("Gemini API Retry (#{retries}/#{MAX_RETRIES}) using #{MODELS[model_index]}: #{e.message}")
        sleep RETRY_DELAY * retries
        retry
      end

      Rails.logger.error("Gemini API Error Detail: #{e.class} - #{e.message}")
      Rails.logger.error(e.backtrace.first(10).join("\n")) if e.backtrace
      raise "AIプランの生成に失敗しました: #{e.message}"
    end
  end
end