using Financeiro.Application.Interfaces;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Net.Mail;
using System.Threading.Tasks;

namespace Financeiro.Infra.Reports
{
    public class SmtpEmailSender : IEmailSender
    {
        private readonly IConfiguration _configuration;

        public SmtpEmailSender(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task SendEmailAsync(string to, string subject, string htmlBody, IEnumerable<(string FileName, byte[] Content)>? attachments = null)
        {
            var smtpSection = _configuration.GetSection("Smtp");
            var host = smtpSection.GetValue<string>("Host");
            var port = smtpSection.GetValue<int?>("Port") ?? 25;
            var user = smtpSection.GetValue<string>("User");
            var pass = smtpSection.GetValue<string>("Password");
            var enableSsl = smtpSection.GetValue<bool?>("EnableSsl") ?? false;
            var from = smtpSection.GetValue<string>("From") ?? user;

            using var message = new MailMessage();
            message.From = new MailAddress(from);
            message.To.Add(new MailAddress(to));
            message.Subject = subject;
            message.IsBodyHtml = true;
            message.Body = htmlBody ?? string.Empty;

            if (attachments != null)
            {
                foreach (var att in attachments)
                {
                    var ms = new MemoryStream(att.Content ?? Array.Empty<byte>());
                    ms.Position = 0;
                    var attachment = new Attachment(ms, att.FileName ?? "attachment");
                    message.Attachments.Add(attachment);
                }
            }

            using var client = new SmtpClient(host, port)
            {
                EnableSsl = enableSsl
            };

            if (!string.IsNullOrEmpty(user))
            {
                client.Credentials = new NetworkCredential(user, pass);
            }

            await client.SendMailAsync(message).ConfigureAwait(false);
        }
    }
}
