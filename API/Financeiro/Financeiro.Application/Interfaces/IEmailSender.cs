using System.Collections.Generic;
using System.Threading.Tasks;

namespace Financeiro.Application.Interfaces
{
    public interface IEmailSender
    {
        Task SendEmailAsync(string to, string subject, string htmlBody, IEnumerable<(string FileName, byte[] Content)>? attachments = null);
    }
}
