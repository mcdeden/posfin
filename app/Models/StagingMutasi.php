<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class StagingMutasi extends Model
{
    protected $table='staging_mutasi';
    public $fillable = ['loan_id'];
}
