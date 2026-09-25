using Financeiro.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Infra.Data.EntitiesConfiguration
{
    public class ClienteConfiguration : IEntityTypeConfiguration<Cliente>
    {
        public void Configure(EntityTypeBuilder<Cliente> builder)
        {
            builder.HasKey(c => c.Id);
            builder.Property(c => c.Nome)
                .IsRequired()
                .HasMaxLength(200);
            builder.Property(c => c.Cpf)
                .IsRequired()
                .HasMaxLength(14);
            builder.Property(c => c.Email)
                .HasMaxLength(200);
            builder.Property(c => c.Telefone)
                .HasMaxLength(20);
            builder.Property(c => c.DataCadastro)
                .HasDefaultValueSql("CURRENT_TIMESTAMP");
        }
    }
}
