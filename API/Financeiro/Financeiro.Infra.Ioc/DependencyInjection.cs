using Financeiro.Application.Interfaces;
using Financeiro.Application.Services;
using Financeiro.Domain.Interfaces;
using Financeiro.Infra.Data.Context;
using Financeiro.Infra.Data.Repositories;
using Financeiro.Infra.Reports;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Infra.Ioc
{
    public static class DependencyInjection
    {
        public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
        {
            services.AddDbContext<ApplicationDbContext>(options =>
            {
                options.UseFirebird(configuration.GetConnectionString("DefaultConnection"), b => b.MigrationsAssembly(typeof(ApplicationDbContext).Assembly.FullName));
            });

            services.AddScoped<IClienteRepository, ClienteRepository>();
            services.AddScoped<IProdutoRepository, ProdutoRepository>();
            services.AddScoped<IPagamentoRepository, PagamentoRepository>();
            services.AddScoped<IVendaRepository, VendaRepository>();
            services.AddScoped<IVendaItemRepository, VendaItemRepository>();

            services.AddScoped<IClienteService, ClienteService>();
            services.AddScoped<IProdutoService, ProdutoService>();
            services.AddScoped<IPagamentoService, PagamentoService>();
            services.AddScoped<IVendaService, VendaService>();
            services.AddScoped<IVendaItemService, VendaItemService>();

            services.AddScoped<IPdfGenerator, QuestPdfGenerator>();

            services.AddScoped<IEmailSender, SmtpEmailSender>();

            return services;
        }
    }
}
